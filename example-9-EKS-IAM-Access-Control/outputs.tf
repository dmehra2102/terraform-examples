output "cluster_name" {
    description = "EKS cluster name"
    value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
    description = "EKS cluster endpoint"
    value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
    description = "EKS cluster Kubernetes version"
    value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority" {
    description = "EKS cluster certificate authority data"
    value       = aws_eks_cluster.main.certificate_authority[0].data
    sensitive   = true
}

output "cluster_iam_role_arn" {
    description = "EKS cluster IAM role ARN"
    value       = aws_iam_role.eks_cluster_role.arn
}

output "cluster_security_group_id" {
    description = "EKS cluster security group ID"
    value       = aws_security_group.eks_cluster.id
}

output "node_group_id" {
    description = "EKS node group ID"
    value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
    description = "EKS node group ARN"
    value       = aws_eks_node_group.main.arn
}

output "node_iam_role_arn" {
    description = "EKS node IAM role ARN"
    value       = aws_iam_role.eks_node_role.arn
}

# ============================================================================
# IAM Roles and Groups Outputs
# ============================================================================

output "admin_group_name" {
    description = "IAM group name for cluster admins"
    value       = aws_iam_group.admin_group.name
}

output "developers_group_name" {
    description = "IAM group name for developers"
    value       = aws_iam_group.developer_group.name
}

output "readers_group_name" {
    description = "IAM group name for readers"
    value       = aws_iam_group.eks_readers.name
}

output "devops_group_name" {
    description = "IAM group name for DevOps"
    value       = aws_iam_group.eks_devops.name
}

output "admin_role_arn" {
    description = "Admin IAM role ARN for AssumeRole"
    value       = aws_iam_role.eks_admin_role.arn
}

output "developer_role_arn" {
    description = "Developer IAM role ARN for AssumeRole"
    value       = aws_iam_role.eks_developer_role.arn
}

output "reader_role_arn" {
    description = "Reader IAM role ARN for AssumeRole"
    value       = aws_iam_role.eks_reader_role.arn
}

output "devops_role_arn" {
    description = "DevOps IAM role ARN for AssumeRole"
    value       = aws_iam_role.eks_devops_role.arn
}

# ============================================================================
# Kubernetes Resources Outputs
# ============================================================================

output "dev_namespace" {
    description = "Kubernetes dev namespace"
    value       = kubernetes_namespace_v1.dev.metadata[0].name
}

output "staging_namespace" {
    description = "Kubernetes staging namespace"
    value       = kubernetes_namespace_v1.staging.metadata[0].name
}

output "prod_namespace" {
    description = "Kubernetes prod namespace"
    value       = kubernetes_namespace_v1.prod.metadata[0].name
}

output "configure_kubectl" {
    description = "Command to configure kubectl"
    value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "assume_admin_role" {
    description = "Command to assume admin role"
    value       = "aws sts assume-role --role-arn ${aws_iam_role.eks_admin_role.arn} --role-session-name admin-session"
}

output "assume_developer_role" {
    description = "Command to assume developer role"
    value       = "aws sts assume-role --role-arn ${aws_iam_role.eks_developer_role.arn} --role-session-name developer-session"
}