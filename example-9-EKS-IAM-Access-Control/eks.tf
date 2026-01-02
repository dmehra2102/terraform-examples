# Security Group for EKS Cluster Plane
resource "aws_security_group" "eks_cluster" {
    name_prefix = "${local.cluster_name}-cluster"
    vpc_id = var.vpc_id
    description = "Security group for EKS cluster control plane"

    egress {
        cidr_blocks = [ "0.0.0.0/0" ]
        to_port = 0
        from_port = 0
        protocol = "-1"
    }

    tags = merge(local.common_tags,{
        Name = "${local.cluster_name}-cluster-sg"
    })
}

# CloudWatch Logs for EKS Cluster
resource "aws_cloudwatch_log_group" "eks_cluster" {
    count = var.enable_logging ? 1 : 0
    name_prefix = "/aws/eks/${local.cluster_name}/cluster"
    retention_in_days = var.log_retention_days

    tags = local.common_tags
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
    name = var.cluster_name
    version = var.kubernetes_version
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids = var.private_subnet_ids
        endpoint_private_access = var.cluster_endpoint_private_access
        endpoint_public_access  = var.cluster_endpoint_public_access
        security_group_ids = [ aws_security_group.eks_cluster.id ]
    }

    enabled_cluster_log_types = local.cluster_log_types

    access_config {
        authentication_mode = "API_AND_CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = false
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_cluster_policy,
        aws_iam_role_policy_attachment.eks_vpc_resource_controller
    ]

    tags = local.common_tags
}