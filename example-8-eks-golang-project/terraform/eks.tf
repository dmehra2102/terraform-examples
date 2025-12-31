# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
    name        = "${var.project_name}-eks-cluster-sg"
    description = "Security group for EKS cluster control plane"
    vpc_id      = aws_vpc.main.id

    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = {
        Name = "${var.project_name}-eks-cluster-sg"
    }
}

# Eks Cluster Control Plane Role
resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.project_name}-eks_cluster_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role       = aws_iam_role.eks_cluster_role.name
}


# EKS Cluster
resource "aws_eks_cluster" "main" {
    name = "${var.project_name}-eks-cluster"
    version = var.eks_cluster_version
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
        security_group_ids      = [aws_security_group.eks_cluster.id]
        endpoint_private_access = true
        endpoint_public_access  = true
    }

    access_config {
        authentication_mode = "API_AND_CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }

    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    tags = {
        Name = "${var.project_name}-cluster"
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_cluster_policy,
        aws_iam_role_policy_attachment.eks_vpc_resource_controller_policy
    ]
}