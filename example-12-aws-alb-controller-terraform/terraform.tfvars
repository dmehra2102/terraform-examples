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