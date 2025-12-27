output "availability_zones" {
    value = data.aws_availability_zones.availability_zones.names
}

output "security_groups_name" {
    value = [ module.vpc.allow_only_ssh_ipv4_sg_name, module.vpc.allow_ssh_http_https_ipv4_sg_name]
}

output "eks_cluster_control_plane_role" {
    value = module.eks_cluster.eks_cluster_control_plane_role
}

output "eks_cluster_worker_node_role" {
    value = module.eks_cluster.eks_cluster_worker_node_role
}

output "eks_cluster_arn" {
    value = module.eks_cluster.eks_cluster_arn
}

output "eks_cluster_api_server_endpoint" {
    value = module.eks_cluster.eks_cluster_api_server_endpoint
}

output "eks_worker_node_group_id" {
    value = module.eks_cluster.eks_worker_node_group_id
}

output "eks_cluster_id" {
    value = module.eks_cluster.eks_cluster_id
}

output "eks_certificate_authority_data" {
    value = module.eks_cluster.eks_certificate_authority_data
}