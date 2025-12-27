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

output "eks_woker_node_group_id" {
    value = aws_eks_node_group.private_worker_node_group.id
}