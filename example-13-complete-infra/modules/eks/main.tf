# IAM Role for Control Plane Cluster
resource "aws_iam_role" "cluster" {
    name = "${var.name_prefix}-eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid  = "ClusterRole"
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "eks.amazonas.com"
                }
            }
        ]
    })

    tags = merge(var.tags, {
        Name = "${var.name_prefix}-eks-cluster-role"
    })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    role = aws_iam_role.cluster.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKS_VPC_ResourceController" {
    role = aws_iam_role.cluster.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_cloudwatch_log_group" "cluster" {
    name = "/aws/eks/${var.cluster_name}/cluster"
    retention_in_days = var.log_retention_days

    tags = merge(var.tags, { 
        "Name" = "${var.cluster_name}-cwlg" 
    })
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
    name = var.cluster_name
    role_arn = aws_iam_role.cluster.arn

    version = var.cluster_version

    vpc_config {
        subnet_ids = var.private_subnet_ids
        endpoint_private_access = var.endpoint_private_access
        endpoint_public_access = var.endpoint_public_access
        public_access_cidrs = var.public_access_cidrs
    }


    kubernetes_network_config {
        service_ipv4_cidr = var.service_ipv4_cidr
    }

    enabled_cluster_log_types = var.enabled_cluster_log_types

    encryption_config {
        provider {
            key_arn = var.kms_key_arn
        }
        resources = [ "secrets" ]
    }

    tags = merge(var.tags,{ 
        "Name" = var.cluster_name 
    })

    depends_on = [ 
        aws_cloudwatch_log_group.cluster,
        aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy_policy_attachement,
        aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController_policy_attachement
    ]
}

# Node Group IAM Role
resource "aws_iam_role" "node" {
    name = "${var.name_prefix}-eks-node-role"
    assume_role_policy = jsondecode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "WorkerNodeGroupRole"
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = merge(var.tags, {
        Name = "${var.name_prefix}-eks-node-role"
    })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
    role = aws_iam_role.node.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
    role = aws_iam_role.node.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
    role = aws_iam_role.node.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "default" {
    cluster_name = aws_eks_cluster.this.name
    node_group_name = "${var.name_prefix}-ng-default"
    node_role_arn = aws_iam_role.node.arn
    subnet_ids = var.private_subnet_ids

    scaling_config {
        desired_size = var.node_desired_size
        max_size = var.node_max_size
        min_size = var.node_min_size
    }
    
    ami_type       = var.node_ami_type
    instance_types = var.node_instance_types
    capacity_type  = var.node_capacity_type

    disk_size = var.node_disk_size

    labels = var.node_labels

    update_config {
        max_unavailable_percentage = 33
    }

    tags = merge(var.tags, { 
        Name = "${var.name_prefix}-ng-default" 
    })  
}