data "aws_caller_identity" "current" {}

module "networking" {
    source = "./networking"

    vpc_cidr                = var.vpc_cidr
    environment             = var.environment
    common_tags             = var.common_tags
    project_name            = var.project_name
    log_retention_days      = var.log_retention_days
    availability_zones      = var.availability_zones
    private_subnet_cidrs    = var.public_subnet_cidrs
    public_subnet_cidrs     = var.private_subnet_cidrs
}

module "security" {
    source = "./security"

    common_tags     = var.common_tags
    environment     = var.environment
    project_name    = var.project_name
    vpc_id          = module.networking.vpc_id
    container_port  = var.container_port
}

module "ecr" {
    source = "./ecr"

    common_tags                     = var.common_tags
    environment                     = var.environment
    project_name                    = var.project_name
    image_tag_mutability            = var.ecr_image_tag_mutability
    untagged_image_expiration_days  = var.ecr_untagged_image_expiration_days
}

module "alb" {
    source = "./alb"

    common_tags                         = var.common_tags
    environment                         = var.environment
    project_name                        = var.project_name
    vpc_id                              = module.networking.vpc_id
    alb_security_group_id               = module.security.alb_security_group_id
    acm_certificate_arn                 = var.acm_certificate_arn
    idle_timeout                        = var.alb_idle_timeout
    health_check_path                   = var.health_check_path
    health_check_interval               = var.health_check_interval
    health_check_timeout                = var.health_check_timeout
    health_check_healthy_threshold      = var.health_check_healthy_threshold
    health_check_unhealthy_threshold    = var.health_check_unhealthy_threshold
    container_port                      = var.container_port
    public_subnet_ids                   = module.networking.public_subnet_ids
}

module "ecs" {
    source = "./ecs"

    project_name                = var.project_name
    environment                 = var.environment
    common_tags                 = var.common_tags
    aws_region                  = var.aws_region
    account_id                  = data.aws_caller_identity.current.account_id
    vpc_id                      = module.networking.vpc_id
    private_subnet_ids          = module.networking.private_subnet_ids
    ecs_task_security_group_id  = module.security.ecs_task_security_group_id
    target_group_arn            = module.alb.target_group_arn
    ecr_repository_url          = module.ecr.repository_url
    container_name              = var.container_name
    container_port              = var.container_port
    task_cpu                    = var.task_cpu
    task_memory                 = var.task_memory
    desired_count               = var.desired_count
    min_capacity                = var.min_capacity
    max_capacity                = var.max_capacity
    cpu_target_value            = var.cpu_target_value
    memory_target_value         = var.memory_target_value
    scale_in_cooldown           = var.scale_in_cooldown
    scale_out_cooldown          = var.scale_out_cooldown
    log_retention_days          = var.log_retention_days
    database_secret_arn         = var.database_secret_arn
    parameter_store_paths       = var.parameter_store_paths
    s3_bucket_arns              = var.s3_bucket_arns
    enable_execute_command      = var.enable_execute_command
}