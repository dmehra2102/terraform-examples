variable "aws_region" {
    type = string
    description = "The AWS Region for resources"
    default = "ap-south-1"
}

variable "common_tags" {
    type        = map(string)
    description = "Common tags to apply to all resources"
    default = {
        Project     = "golang-app"
        Environment = "production"
        ManagedBy   = "Terraform"
    }
}

variable "environment" {
    type = string
    description = "Environment name (dev, staging, prod)"
    default = "production"
}

variable "project_name" {
    type = string
    description = "Project name for resource naming"
    default = "golang-app"
}

# --------------------------------------
#  Networking Configuration
# --------------------------------------
variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "availability_zones" {
    type = list(string)
    description = "List of availability zone"
    default = [ "ap-south-1a","ap-south-1b" ]
}

variable "public_subnet_cidrs" {
    description = "CIDR blocks for public subnets"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
    description = "CIDR blocks for private subnets"
    type        = list(string)
    default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# ============================================
# ALB Configuration
# ============================================
variable "acm_certificate_arn" {
    description = "ARN of ACM certificate for HTTPS listener"
    type        = string
}

variable "alb_idle_timeout" {
    description = "Idle timeout for ALB in seconds"
    type        = number
    default     = 60
}

variable "health_check_path" {
    description = "Health check path for target group"
    type        = string
    default     = "/health"
}

variable "health_check_interval" {
    description = "Health check interval in seconds"
    type        = number
    default     = 30
}

variable "health_check_timeout" {
    description = "Health check timeout in seconds"
    type        = number
    default     = 5
}

variable "health_check_healthy_threshold" {
    description = "Number of consecutive health checks successes required"
    type        = number
    default     = 2
}

variable "health_check_unhealthy_threshold" {
    description = "Number of consecutive health check failures required"
    type        = number
    default     = 3
}

# ============================================
# ECS Configuration
# ============================================
variable "container_name" {
    type = string
    description = "Name of the container"
    default = "golang-app"
}

variable "container_port" {
    type = number
    description = "Port exposed by the container"
    default = 8080
}

variable "task_cpu" {
    type = number
    description = "CPU units for the task (1024 = 1 vCPU)"
    default = 512
}

variable "task_memory" {
    type = number
    default = 1024
    description = "Memory for the task in MiB"
}

variable "desired_count" {
    type        = number
    description = "Desired number of tasks"
    default     = 3
}

variable "min_capacity" {
    type        = number
    description = "Minimum number of tasks for autoscaling"
    default     = 2
}

variable "max_capacity" {
    type        = number
    description = "Maximum number of tasks for autoscaling"
    default     = 10
}

variable "cpu_target_value" {
    type        = number
    description = "Target CPU utilization percentage for autoscaling"
    default     = 70
}

variable "memory_target_value" {
    type        = number
    description = "Target memory utilization percentage for autoscaling"
    default     = 80
}

variable "scale_in_cooldown" {
    type        = number
    description = "Cooldown period in seconds for scale-in actions"
    default     = 300
}

variable "scale_out_cooldown" {
    type        = number
    description = "Cooldown period in seconds for scale-out actions"
    default     = 60
}

# ============================================
# CloudWatch Configuration
# ============================================
variable "log_retention_days" {
    type        = number
    description = "CloudWatch log retention in days"
    default     = 30
}


# ============================================
# ECR Configuration
# ============================================
variable "ecr_image_tag_mutability" {
    type        = string
    description = "Tag mutability setting for ECR repository"
    default     = "MUTABLE"
}

variable "ecr_untagged_image_expiration_days" {
    type        = number
    description = "Days after which untagged images expire"
    default     = 14
}

# ============================================
# Application Configuration
# ============================================
variable "database_secret_arn" {
    type        = string
    description = "ARN of Secrets Manager secret containing database credentials"
    default     = ""
}

variable "parameter_store_paths" {
    type        = list(string)
    description = "List of SSM Parameter Store paths the application needs access to"
    default     = []
}

variable "s3_bucket_arns" {
    type        = list(string)
    description = "List of S3 bucket ARNs the application needs access to"
    default     = []
}

variable "enable_execute_command" {
    type        = bool
    description = "Enable ECS Exec for debugging"
    default     = false
}