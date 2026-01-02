variable "aws_region" {
    type = string
    default = "ap-south-1"
    description = "AWS region for resources"
}

variable "environment" {
    type = string
    default = "prod"
    description = "Environment name"

    validation {
        condition = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Encironment must be dev,staging, or prod."
    }
}

variable "project_name" {
    type = string
    default = "myapp"
    description = "Project name for resource naming"

    validation {
        condition     = can(regex("^[a-z0-9-]+$", var.project_name))
        error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
    }
}

variable "cluster_name" {
    type = string
    description = "The name for the EKS cluster"
}

variable "kubernetes_version" {
    type        = string
    default     = "1.34"
    description = "Kubernetes version for EKS cluster"
}

variable "cluster_endpoint_public_access" {
    type = bool
    default = false
    description = "Enable public access to cluster endpoint"
}

variable "cluster_endpoint_private_access" {
    type = bool
    default = true
    description = "Enable private access to cluster endpoint"
}

variable "enable_cluster_autoscaler" {
    description = "Enable cluster autoscaler addon"
    type        = bool
    default     = true
}

variable "enable_vpc_cni" {
    description = "Enable AWS VPC CNI addon"
    type        = bool
    default     = true
}

variable "vpc_id" {
    description = "VPC ID for EKS cluster"
    type        = string
}

variable "private_subnet_ids" {
    description = "Private subnet IDs for EKS nodes"
    type        = list(string)
}

variable "desired_node_count" {
    description = "Desired number of worker nodes"
    type        = number
    default     = 3

    validation {
        condition     = var.desired_node_count >= 1 && var.desired_node_count <= 100
        error_message = "Desired node count must be between 1 and 100."
    }
}

variable "node_instance_types" {
    description = "EC2 instance types for worker nodes"
    type        = list(string)
    default     = ["t3.medium"]
}

variable "node_disk_size" {
    description = "Disk size for worker nodes in GiB"
    type        = number
    default     = 100
}

variable "admin_users" {
    description = "List of IAM usernames for admin access"
    type        = list(string)
    default     = []
}

variable "admin_roles" {
    description = "List of IAM role ARNs for admin access"
    type        = list(string)
    default     = []
}

variable "developer_users" {
    description = "List of IAM usernames for developer access"
    type        = list(string)
    default     = []
}

variable "developer_roles" {
    description = "List of IAM role ARNs for developer access"
    type        = list(string)
    default     = []
}

variable "reader_users" {
    description = "List of IAM usernames for read-only access"
    type        = list(string)
    default     = []
}

variable "reader_roles" {
    description = "List of IAM role ARNs for read-only access"
    type        = list(string)
    default     = []
}

variable "devops_users" {
    description = "List of IAM usernames for DevOps access"
    type        = list(string)
    default     = []
}

variable "devops_roles" {
    description = "List of IAM role ARNs for DevOps access"
    type        = list(string)
    default     = []
}

variable "enable_logging" {
    description = "Enable EKS cluster logging"
    type        = bool
    default     = true
}

variable "log_retention_days" {
    description = "CloudWatch log retention in days"
    type        = number
    default     = 30
}

variable "tags" {
    description = "Additional tags to apply to resources"
    type        = map(string)
    default     = {}
}