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