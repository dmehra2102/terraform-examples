output "cluster_name" {
    value       = module.eks.cluster_name
    description = "EKS cluster name"
}

output "cluster_endpoint" {
    value       = module.eks.cluster_endpoint
    description = "EKS cluster endpoint"
}

output "cluster_ca_certificate" {
    value       = module.eks.cluster_certificate_authority_data
    description = "EKS cluster CA certificate"
}

output "vpc_id" {
    value       = module.vpc.vpc_id
    description = "VPC ID"
}

output "private_subnet_ids" {
    value       = module.vpc.private_subnet_ids
    description = "Private subnet IDs"
}

output "configure_kubectl_command" {
    value = format(
        "aws eks update-kubeconfig --name %s --region %s",
        module.eks.cluster_name,
        var.aws_region
    )
    description = "Command to configure kubectl"
}
