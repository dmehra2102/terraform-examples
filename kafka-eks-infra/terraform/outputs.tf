output "cluster_name" {
    description = "EKS cluster name"
    value       = module.eks.cluster_name
}

output "cluster_endpoint" {
    description = "Endpoint for EKS control plane"
    value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
    description = "Base64 encoded certificate data required to communicate with the cluster"
    value       = module.eks.cluster_certificate_authority_data
    sensitive   = true
}

output "cluster_oidc_issuer_url" {
    description = "The URL on the EKS cluster OIDC Issuer"
    value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_security_group_id" {
    description = "Security group ID attached to the EKS cluster"
    value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
    description = "Security group ID attached to the EKS nodes"
    value       = module.eks.node_security_group_id
}

output "vpc_id" {
    description = "VPC ID where the cluster is deployed"
    value       = module.vpc.vpc_id
}

output "private_subnets" {
    description = "List of private subnet IDs"
    value       = module.vpc.private_subnets
}

output "public_subnets" {
    description = "List of public subnet IDs"
    value       = module.vpc.public_subnets
}

output "configure_kubectl" {
    description = "Command to configure kubectl"
    value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ebs_csi_driver_role_arn" {
    description = "ARN of IAM role for EBS CSI Driver"
    value       = module.ebs_csi_irsa.arn
}

output "aws_lb_controller_role_arn" {
    description = "ARN of IAM role for AWS Load Balancer Controller"
    value       = module.aws_lb_controller_irsa.arn
}

output "controller_node_group_name" {
    description = "Name of the Kafka controller node group"
    value       = "pool-controllers"
}

output "broker_node_group_name" {
    description = "Name of the Kafka broker node group"
    value       = "pool-brokers"
}

output "strimzi_installed" {
    description = "Whether Strimzi operator was installed"
    value       = var.install_strimzi
}

output "aws_region" {
    description = "AWS region used for deployment"
    value       = var.aws_region
}

output "availability_zones" {
    description = "Availability zones used for the cluster"
    value       = var.availability_zones
}
