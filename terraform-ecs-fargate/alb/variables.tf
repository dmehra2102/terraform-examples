variable "project_name" {
    description = "Project name for resource naming"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type        = string
}

variable "public_subnet_ids" {
    description = "IDs of public subnets"
    type        = list(string)
}

variable "alb_security_group_id" {
    description = "Security group ID for ALB"
    type        = string
}

variable "acm_certificate_arn" {
    description = "ARN of ACM certificate for HTTPS"
    type        = string
}

variable "idle_timeout" {
    description = "Idle timeout for ALB in seconds"
    type        = number
}

variable "health_check_path" {
    description = "Health check path"
    type        = string
}

variable "health_check_interval" {
    description = "Health check interval in seconds"
    type        = number
}

variable "health_check_timeout" {
    description = "Health check timeout in seconds"
    type        = number
}

variable "health_check_healthy_threshold" {
    description = "Healthy threshold for health checks"
    type        = number
}

variable "health_check_unhealthy_threshold" {
    description = "Unhealthy threshold for health checks"
    type        = number
}

variable "container_port" {
    description = "Port exposed by the container"
    type        = number
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
}