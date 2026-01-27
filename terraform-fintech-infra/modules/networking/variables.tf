variable "environment" {
    type = string
    description = "Environment name (dev/staging/prod)"
    validation {
        condition = contains(["dev","staging","prod"], var.environment)
        error_message = "Environment must be dev, staging, or prod."
    }
}

variable "vpc_cidr" {
    type = string
    description = "CIDR block for VPC"
    validation {
        condition = can(cidrhost(var.vpc_cidr, 0))
        error_message = "Must be a valid IPv4 CIDR block."
    }
}

variable "az_count" {
    type = number
    description = "Number of Availability Zones"
    default = 3
    validation {
        condition = var.az_count >= 2 && var.az_count <= 3
        error_message = "AZ count must be 2 or 3 for production workloads."
    }
}

variable "cluster_name" {
    description = "EKS cluster name for subnet tagging"
    type        = string
}

variable "tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
    default     = {}
}