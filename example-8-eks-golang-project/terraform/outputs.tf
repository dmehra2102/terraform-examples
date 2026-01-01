output "eks_cluster_name" {
    description = "EKS cluster name"
    value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
    description = "EKS cluster endpoint"
    value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
    description = "EKS cluster version"
    value       = aws_eks_cluster.main.version
}

output "eks_cluster_arn" {
    description = "EKS cluster ARN"
    value       = aws_eks_cluster.main.arn
}

output "oidc_provider_arn" {
    description = "OIDC Provider ARN for IRSA"
    value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_issuer_url" {
    description = "OIDC issuer URL"
    value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "golang_app_role_arn" {
    description = "IAM role ARN for Golang app (IRSA)"
    value       = aws_iam_role.golang_app.arn
}

output "alb_controller_role_arn" {
    description = "IAM role ARN for ALB controller"
    value       = aws_iam_role.alb_controller.arn
}

output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
}

output "private_subnet_ids" {
    description = "Private subnet IDs"
    value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
    description = "Public subnet IDs"
    value       = aws_subnet.public[*].id
}

output "configure_kubectl_command" {
    description = "Command to configure kubectl"
    value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
}