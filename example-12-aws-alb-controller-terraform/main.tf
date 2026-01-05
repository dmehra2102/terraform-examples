# ============================================
# VPC Module
# ============================================
module "vpc" {
    source = "./modules/vpc"

    name_prefix     = local.name_prefix
    vpc_cidr        = var.vpc_cidr
    az_count        = 2
    common_tags     = local.common_tags
    public_subnets_cidr = var.public_subnets_cidr
    private_subnets_cidr = var.private_subnets_cidr
}

# ============================================
# EKS Module
# ============================================
module "eks" {
    source = "./modules/eks"

    vpc_id = module.vpc.vpc_id
    name_prefix     = local.name_prefix
    common_tags     = local.common_tags
    cluster_version = var.cluster_version
    worker_min_size = var.worker_min_size
    worker_max_size = var.worker_max_size
    worker_desired_size = var.worker_desired_size
    enable_spot_instances = var.enable_spot_instances
    worker_instance_types = var.worker_instance_types
    private_subnet_ids = module.vpc.private_subnet_ids
    vpc_cidr_block = var.vpc_cidr
}