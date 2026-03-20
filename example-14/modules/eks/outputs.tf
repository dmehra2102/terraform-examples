output "cluster_name"                       { value = aws_eks_cluster.main.name }
output "cluster_endpoint"                   { value = aws_eks_cluster.main.endpoint }
output "cluster_certificate_authority_data" { value = aws_eks_cluster.main.certificate_authority[0].data }
output "cluster_arn"                        { value = aws_eks_cluster.main.arn }
output "cluster_version"                    { value = aws_eks_cluster.main.version }
output "node_security_group_id"             { value = aws_security_group.nodes.id }
output "cluster_security_group_id"          { value = aws_security_group.cluster.id }
output "oidc_provider_arn"                  { value = aws_iam_openid_connect_provider.eks.arn }
output "oidc_provider_url"                  { value = aws_iam_openid_connect_provider.eks.url }
output "node_role_arn"                      { value = aws_iam_role.node_group.arn }
output "karpenter_irsa_role_arn" {
  value = var.enable_karpenter ? aws_iam_role.karpenter_controller[0].arn : null
}
output "karpenter_interruption_queue_url" {
  value = var.enable_karpenter ? aws_sqs_queue.karpenter_interruption[0].id : null
}