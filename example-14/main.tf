data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.region
  name_prefix = "${var.project_name}-${var.environment}"

  ommon_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Region      = local.region
  }
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix           = local.name_prefix
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway
  enable_flow_logs      = var.enable_vpc_flow_logs
  log_retention_days    = var.log_retention_days
  cluster_name          = "${local.name_prefix}-eks"
}

# =============================================================================
# MODULE: SECURITY (KMS, IAM foundations, Secrets Manager baseline)
# =============================================================================
module "security" {
  source = "./modules/security"

  name_prefix      = local.name_prefix
  aws_region       = local.region
  account_id       = local.account_id
  eks_cluster_name = "${local.name_prefix}-eks"
}