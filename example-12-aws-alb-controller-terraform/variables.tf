variable "aws_region" {
    type = string
    description = "AWS Region"
    default = "ap-south-1"
}

variable "cluster_name" {
    type = string
    default = "The name of the cluster"
}

variable "project_name" {
    type        = string
    default     = "alb-controller-demo"
    description = "Project name prefix"
}

variable "environment" {
    type        = string
    default     = "dev"
    description = "Environment (dev, staging, prod)"
}

variable "vpc_cidr" {
    type        = string
    default     = "10.0.0.0/16"
    description = "VPC CIDR block"
}

variable "public_subnets_cidr" {
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
    description = "Public subnet CIDR blocks"
}

variable "private_subnets_cidr" {
    type = list(string)
    default = [ "10.0.10.0/24", "10.0.11.0/24" ]
    description = "Private subnet CIDR blocks"
}

variable "cluster_version" {
    type        = string
    default     = "1.30"
    description = "EKS cluster Kubernetes version"
}

variable "worker_instance_types" {
    type        = list(string)
    default     = ["t3.medium"]
    description = "EC2 instance types for worker nodes"
}

variable "worker_desired_size" {
    type        = number
    default     = 2
    description = "Desired number of worker nodes"
}

variable "worker_min_size" {
    type        = number
    default     = 2
    description = "Minimum number of worker nodes"
}

variable "worker_max_size" {
    type        = number
    default     = 4
    description = "Maximum number of worker nodes"
}

variable "enable_spot_instances" {
    type        = bool
    default     = true
    description = "Use spot instances for cost optimization"
}

variable "alb_controller_replicas" {
    type        = number
    default     = 2
    description = "Number of ALB controller replicas"
}

variable "alb_controller_version" {
    type        = string
    default     = "2.8.0"
    description = "AWS Load Balancer Controller Helm chart version"
}

variable "enable_test_application" {
    type        = bool
    default     = true
    description = "Deploy test NGINX application with ALB Ingress"
}

variable "tags" {
    type = map(string)
    default = {
        Project     = "alb-controller"
        Environment = "dev"
        ManagedBy   = "terraform"
    }
    description = "Common tags for all resources"
}