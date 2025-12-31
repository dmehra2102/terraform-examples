variable "region" {
    type = string
    default = "ap-south-1"
    description = "The AWS region where resources will get created."
}

variable "project_name" {
    type = string
    default = "golang-app"
    description = "The name of the project"
}

variable "environment" {
    type = string
    default = "production"
    description = "Environment like Prod, Dev, Stag"
}

variable "vpc_cidr_block" {
    type        = string
    default     = "10.0.0.0/16"
    description = "VPC CIDR block"
}

variable "availability_zones" {
    type = list(string)
    default = [ "ap-south-1a", "ap-south-1b" ]
    description = "List of Availability Zones"
}

variable "public_subnet_cidrs" {
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
    description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
    type        = list(string)
    default     = ["10.0.10.0/24", "10.0.11.0/24"]
    description = "Private subnet CIDRs for EKS nodes"
}

variable "database_subnet_cidrs" {
    type        = list(string)
    default     = ["10.0.20.0/24", "10.0.21.0/24"]
    description = "Database subnet CIDRs"
}

variable "eks_cluster_version" {
    type        = string
    default     = "1.35"
    description = "EKS cluster Kubernetes version"
}

variable "node_group_desired_size" {
    type        = number
    default     = 2
    description = "Desired number of nodes"
}

variable "node_group_min_size" {
    type        = number
    default     = 1
    description = "Minimum number of nodes"
}

variable "node_group_max_size" {
    type        = number
    default     = 4
    description = "Maximum number of nodes"
}

variable "node_instance_types" {
    type        = list(string)
    default     = ["t3.medium"]
    description = "EC2 instance types for nodes"
}

variable "admin_iam_user_arn" {
    type        = string
    description = "ARN of IAM user/role for cluster admin access"
}