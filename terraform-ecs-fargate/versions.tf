terraform {
    required_version = ">= 1.6.0"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }

    backend "s3" {
        bucket = "ecs-fargate-terraform-state-2026"
        key = "terraform.tfstate"
        region = "ap-south-1"
        encrypt = true
        dynamodb_table = "terraform-state-lock"
    }
}

provider "aws" {
    region = var.aws_region

    default_tags {
        tags = var.common_tags
    }
}