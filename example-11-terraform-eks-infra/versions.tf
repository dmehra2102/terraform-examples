terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 3.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = ">= 3.0"
        }
        kubectl = {
            source = "gavinbunney/kubectl"
            version = "~> 1.0"
        }
    }
    
    backend "s3" {
        bucket = "terraform-cluster-example"
        key = "golang-app/terraform.tfstate"
        region = "ap-south-1"
        encrypt = true
        dynamodb_table = "golang-app-table"
    }
}

provider "aws" {
    region = var.aws_region
    default_tags {
        tags = {
            Environment = var.environment
            Project     = var.project_name
            ManagedBy   = "Terraform"
            CreatedAt   = timestamp()
        }
    }
}