terraform {
    required_version = ">= 1.0"
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 3.0"
        }
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }

    backend "s3" {
        bucket = "terraform-kubernetes-example"
        key = "sampleapp-demo/terraform.tfstate"
        region = "ap-south-1"
    }
}