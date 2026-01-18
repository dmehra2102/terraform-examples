# ============================================
# Networking Outputs
# ============================================
output "vpc_id" {
    description = "ID of the VPC"
    value       = module.networking.vpc_id
}

output "public_subnet_ids" {
    description = "IDs of public subnets"
    value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
    description = "IDs of private subnets"
    value       = module.networking.private_subnet_ids
}

# ============================================
# Security Outputs
# ============================================
output "alb_security_group_id" {
    description = "ID of ALB security group"
    value       = module.security.alb_security_group_id
}

output "ecs_task_security_group_id" {
    description = "ID of ECS task security group"
    value       = module.security.ecs_task_security_group_id
}

# ============================================
# ALB Outputs
# ============================================
output "alb_dns_name" {
    description = "DNS name of the Application Load Balancer"
    value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
    description = "Zone ID of the Application Load Balancer"
    value       = module.alb.alb_zone_id
}

output "alb_arn" {
    description = "ARN of the Application Load Balancer"
    value       = module.alb.alb_arn
}

# ============================================
# ECS Outputs
# ============================================
output "ecs_cluster_name" {
    description = "Name of the ECS cluster"
    value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
    description = "ARN of the ECS cluster"
    value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
    description = "Name of the ECS service"
    value       = module.ecs.service_name
}

output "task_definition_arn" {
    description = "ARN of the ECS task definition"
    value       = module.ecs.task_definition_arn
}

output "cloudwatch_log_group_name" {
    description = "Name of the CloudWatch log group"
    value       = module.ecs.cloudwatch_log_group_name
}

# ============================================
# ECR Outputs
# ============================================
output "ecr_repository_url" {
    description = "URL of the ECR repository"
    value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
    description = "ARN of the ECR repository"
    value       = module.ecr.repository_arn
}

# ============================================
# Deployment Information
# ============================================
output "application_url" {
    description = "Application URL (HTTPS)"
    value       = "https://${module.alb.alb_dns_name}"
}

output "deployment_commands" {
    description = "Commands to deploy the application"
    value = <<-EOT
        # 1. Authenticate with ECR
        aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.ecr.repository_url}
        
        # 2. Build your Docker image
        docker build -t ${var.project_name} .
        
        # 3. Tag your image
        docker tag ${var.project_name}:latest ${module.ecr.repository_url}:latest
        
        # 4. Push to ECR
        docker push ${module.ecr.repository_url}:latest
        
        # 5. Force new deployment (if task definition hasn't changed)
        aws ecs update-service --cluster ${module.ecs.cluster_name} --service ${module.ecs.service_name} --force-new-deployment --region ${var.aws_region}
    EOT
}