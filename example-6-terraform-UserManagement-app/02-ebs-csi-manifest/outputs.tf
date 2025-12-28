output "cluster_id" {
    value = aws_eks_cluster.my_eks_cluster.id
}

output "cluster_certificate_authority" {
    value = aws_eks_cluster.my_eks_cluster.certificate_authority[0].data
}

output "cluster_api_endpoint" {
    value = aws_eks_cluster.my_eks_cluster.endpoint
}