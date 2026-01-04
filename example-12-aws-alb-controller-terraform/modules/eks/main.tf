# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
    name = "${var.name_prefix}-eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })

    tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    role       = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKS_VPC_ResourceController" {
    role       = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Security Group for EKS Cluster
resource "aws_security_group" "cluster" {
    name = "${var.name_prefix}-eks-cluster-sg"
    vpc_id = var.vpc_id
    description = "Security group for EKS cluster control plane"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = var.common_tags
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
    name = "${var.name_prefix}-eks"
    role_arn = aws_iam_role.cluster.arn
    version = var.cluster_version

    vpc_config {
        subnet_ids = var.private_subnet_ids
        endpoint_private_access = true
        endpoint_public_access = false
        security_group_ids = [aws_security_group.cluster.id]
    }

    encryption_config {
        provider {
            key_arn = aws_kms_key.eks.arn
        }
        resources = [ "secrets" ]
    }

    enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

    depends_on = [ 
        aws_iam_role_policy_attachment.cluster_AmazonEKS_VPC_ResourceController,
        aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
    ]

    tags = var.common_tags
}

# Add KMS key for EKS encryption
resource "aws_kms_key" "eks" {
    description             = "EKS Secrets Encryption Key"
    deletion_window_in_days = 7
    enable_key_rotation    = true
    
    tags = var.common_tags
}

resource "aws_kms_alias" "eks" {
    name          = "alias/eks-${var.name_prefix}"
    target_key_id = aws_kms_key.eks.key_id
}

# EKS Worker Node IAM Role
resource "aws_iam_role" "node" {
    name = "${var.name_prefix}-eks-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
    role       = aws_iam_role.node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
    role       = aws_iam_role.node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
    role       = aws_iam_role.node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Security Group for Node Workers
resource "aws_security_group" "node" {
    name        = "${var.name_prefix}-eks-node-sg"
    description = "Security group for EKS worker nodes"
    vpc_id      = var.vpc_id

    ingress {
        description     = "Cluster to node kubelet"
        from_port       = 10250
        to_port         = 10250
        protocol        = "tcp"
        security_groups = [aws_security_group.cluster.id]
    }

    ingress {
        description     = "Cluster to node metrics"
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        security_groups = [aws_security_group.cluster.id]
    }

    ingress {
        description = "Node to node all ports"
        from_port   = 0
        to_port     = 65535
        protocol    = "-1"
        self        = true
    } 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = var.common_tags
}

resource "aws_launch_template" "node" {
    name = "${var.name_prefix}-launch-template"
    description = "Launch template for EKS managed node group"
    instance_type  = var.worker_instance_types[0]
    vpc_security_group_ids = [ aws_security_group.node.id ]

    block_device_mappings {
    device_name = "/dev/sdf"

        ebs {
            volume_type           = var.node_disk_type
            encrypted             = var.node_disk_encrypted
            delete_on_termination = true
            volume_size           = 20
        }
    }

    tags = var.common_tags
}

# EKS Worker Node
resource "aws_eks_node_group" "main" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "${var.name_prefix}-node-group"
    subnet_ids =  var.private_subnet_ids
    node_role_arn = aws_iam_role.node.arn
    version = var.cluster_version
    ami_type = var.node_ami_type

    scaling_config {
        desired_size = var.worker_desired_size
        max_size = var.worker_max_size
        min_size = var.worker_min_size
    }

    launch_template {
        id = aws_launch_template.node.id
        version = aws_launch_template.node.latest_version
    }

    update_config {
        max_unavailable_percentage = 33
    }

    labels = {
        Environment = "dev"
        ManagedBy   = "terraform"
    }

    tags = var.common_tags

    depends_on = [
        aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
    ]

}

resource "aws_iam_openid_connect_provider" "cluster" {
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
    url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

    tags = var.common_tags
}