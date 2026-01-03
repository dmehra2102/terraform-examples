variable "aws_region" {
    type = string
    default = "ap-south-1"
    description = "AWS Region"
}

variable "project_name" {
    type = string
    default = "eks-infra"
    description = "The name of the Project"
}

variable "environment" {
    type = string
    description = "Environment name"
    validation {
        condition = contains(["dev","staging","prod"], var.environment)
        error_message = "Environment must be dev, staging, or prod."
    }
}

# VPC Configuration
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "VPC CIDR block"
}

variable "availability_zones" {
    type = list(string)
    default = [ "ap-south-1a", "ap-south-1b" ]
    description = "Availability zones"
}

variable "public_subnet_cidr" {
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
    description = "Public subnet CIDR blocks"
}

variable "private_subnet_cidr" {
    type = list(string)
    default = [ "10.0.10.0/24", "10.0.11.0/24" ]
    description = "Private subnet CIDR blocks"
}

# EKS Configuration
variable "cluster_version" {
    type = string
    default = "1.34"
    description = "Kubernetes Version"
}

variable "node_group_desired_size" {
    type = number
    default = 3
    description = "Desired number of nodes"
}

variable "node_group_min_size" {
    type        = number
    default     = 1
    description = "Minimum number of nodes"
}

variable "node_group_max_size" {
    type        = number
    default     = 10
    description = "Maximum number of nodes"
}

variable "node_instance_types" {
    type        = list(string)
    default     = ["t3.large"]
    description = "EC2 instance types for nodes"
}

variable "enable_spot_instances" {
    type        = bool
    default     = true
    description = "Enable spot instances for cost savings"
}

# Database Configuration
variable "db_instance_class" {
    type = string
    default = "db.t3.micro"
    description = "RDS instance class"
}

variable "db_allocated_storage" {
    type        = number
    default     = 20
    description = "RDS allocated storage in GB"
}

variable "db_engine_version" {
    type        = string
    default     = "15.3"
    description = "PostgreSQL version"
}

variable "enable_rds" {
    type        = bool
    default     = true
    description = "Enable RDS database"
}

variable "enable_elasticache" {
    type        = bool
    default     = true
    description = "Enable ElastiCache"
}

variable "enable_monitoring" {
    type        = bool
    default     = true
    description = "Enable Prometheus and Grafana"
}

variable "tags" {
    type        = map(string)
    default     = {}
    description = "Additional tags"
}