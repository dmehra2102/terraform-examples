terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 3.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = var.region
    default_tags {
        tags = {
            Project     = var.project_name
            Environment = var.environment
            ManagedBy   = "Terraform"
        }
    }
}

provider "kubernetes" {
}

provider "helm" {
}

data "aws_eks_cluster_auth" "main" {
    name = ""
}

data "aws_caller_identity" "current" {
}