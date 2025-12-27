output "eks_cluster_control_plane_role" {
    value = aws_iam_role.eks_cluster_control_plane_role.arn
}

output "eks_cluster_worker_node_role" {
    value = aws_iam_role.eks_cluster_worker_node_role.arn
}

output "eks_cluster_arn" {
    value = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_api_server_endpoint" {
    value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_worker_node_group_id" {
    value = aws_eks_node_group.private_worker_node_group.id
}

output "eks_cluster_id" {
    value = aws_eks_cluster.eks_cluster.id
}

output "eks_certificate_authority_data" {
    value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "aws_iam_openid_connect_provider_arn" {
    value = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "aws_iam_openid_connect_provider_extract_from_arn" {
    value = local.aws_iam_oidc_connect_provider_extract_from_arn
}