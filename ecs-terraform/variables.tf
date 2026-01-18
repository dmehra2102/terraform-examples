variable "aws_region" {
    type = string
    description = "AWS region for resources"
    default = "ap-south-1"
}

variable "project_name" {
    type = string
    description = "The name of the project"
    default = "ecs-prod-demo"
}