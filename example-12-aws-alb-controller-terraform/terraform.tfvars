# Project Configuration
project_name    = "alb-controller-demo"
environment     = "dev"
aws_region      = "ap-south-1"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
tags = {
    Project     = "alb-controller"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
}

cluster_version      = "1.34"
worker_instance_types = ["t3.medium"]
worker_desired_size = 2
worker_min_size = 1
worker_max_size = 2