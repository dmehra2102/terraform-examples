variable "project_name" {
    type        = string
    description = "Project name for resource naming"
}

variable "environment" {
    type        = string
    description = "Environment name"
}

variable "vpc_id" {
    type        = string
    description = "ID of the VPC"
}

variable "container_port" {
    type        = number
    description = "Port exposed by the container"
}

variable "common_tags" {
    type        = map(string)
    description = "Common tags to apply to all resources"
}