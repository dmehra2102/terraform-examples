resource "aws_iam_role" "cluster" {
    name = "${var.cluster_name}-cluster-role"
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

    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
    role       = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_controller_policy" {
    role = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Creating KMS key for encryption
resource "aws_kms_key" "eks" {
    description = "KMS key for EKS cluster ${var.cluster_name}"
    deletion_window_in_days = 10
    enable_key_rotation = true

    tags = merge(var.tags,{
        Name = "${var.cluster_name}-kms"
    })
}

resource "aws_kms_alias" "eks" {
    name          = "alias/${var.cluster_name}-eks"
    target_key_id = aws_kms_key.eks.key_id
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
    name = var.cluster_name
    version = var.cluster_version
    role_arn = aws_iam_role.cluster.arn

    vpc_config {
        endpoint_private_access = true
        endpoint_public_access = true
        subnet_ids = var.private_subnet_ids
        security_group_ids = [ aws_security_group.cluster.id ]
    }

    encryption_config {
        provider {
            key_arn = aws_kms_key.eks.arn
        }
        resources = [ "secrets" ]
    }

    enabled_cluster_log_types = [
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
    ]

    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy,
        aws_iam_role_policy_attachment.eks_vpc_controller_policy,
        aws_cloudwatch_log_group.cluster
    ]
}

resource "aws_cloudwatch_log_group" "cluster" {
    name              = "/aws/eks/${var.cluster_name}/cluster"
    retention_in_days = 7

    tags = var.tags
}

# Security Group for Cluster
resource "aws_security_group" "cluster" {
    name_prefix = "${var.cluster_name}-"
    vpc_id      = var.vpc_id
    description = "Security group for ${var.cluster_name} EKS cluster"
    
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = merge(
        var.tags,
        {
            Name = "${var.cluster_name}-cluster-sg"
        }
    )
}