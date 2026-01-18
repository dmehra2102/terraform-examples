variable "project_name" {
    description = "Project name for resource naming"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "aws_region" {
    description = "AWS region"
    type        = string
}

variable "account_id" {
    description = "AWS account ID"
    type        = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type        = string
}

variable "private_subnet_ids" {
    description = "IDs of private subnets"
    type        = list(string)
}

variable "ecs_task_security_group_id" {
    description = "Security group ID for ECS tasks"
    type        = string
}

variable "target_group_arn" {
    description = "ARN of the target group"
    type        = string
}

variable "ecr_repository_url" {
    description = "URL of the ECR repository"
    type        = string
}

variable "container_name" {
    description = "Name of the container"
    type        = string
}

variable "container_port" {
    description = "Port exposed by the container"
    type        = number
}

variable "task_cpu" {
    description = "CPU units for the task"
    type        = number
}

variable "task_memory" {
    description = "Memory for the task in MiB"
    type        = number
}

variable "desired_count" {
    description = "Desired number of tasks"
    type        = number
}

variable "min_capacity" {
    description = "Minimum capacity for autoscaling"
    type        = number
}

variable "max_capacity" {
    description = "Maximum capacity for autoscaling"
    type        = number
}

variable "cpu_target_value" {
    description = "Target CPU utilization for autoscaling"
    type        = number
}

variable "memory_target_value" {
    description = "Target memory utilization for autoscaling"
    type        = number
}

variable "scale_in_cooldown" {
    description = "Scale-in cooldown in seconds"
    type        = number
}

variable "scale_out_cooldown" {
    description = "Scale-out cooldown in seconds"
    type        = number
}

variable "log_retention_days" {
    description = "CloudWatch log retention in days"
    type        = number
}

variable "database_secret_arn" {
    description = "ARN of database secret in Secrets Manager"
    type        = string
}

variable "parameter_store_paths" {
    description = "List of SSM Parameter Store paths"
    type        = list(string)
}

variable "s3_bucket_arns" {
    description = "List of S3 bucket ARNs"
    type        = list(string)
}

variable "enable_execute_command" {
    description = "Enable ECS Exec"
    type        = bool
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
}