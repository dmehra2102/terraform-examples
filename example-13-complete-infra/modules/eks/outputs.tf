output "cluster_name" {
    value       = aws_eks_cluster.this.name
    description = "EKS cluster name."
}

output "cluster_endpoint" {
    value       = aws_eks_cluster.this.endpoint
    description = "EKS cluster endpoint."
}

output "cluster_ca" {
    value       = aws_eks_cluster.this.certificate_authority[0].data
    description = "EKS cluster CA."
}

output "node_group_name" {
    value       = aws_eks_node_group.default.node_group_name
    description = "Default node group name."
}

output "cluster_security_group_id" {
    value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    description = "Cluster security group ID."
}
