terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
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

    backend "local" {
        path = "terraform.tfstate"
    }

    # For Production
    # backend "s3" {
    #     bucket = "terraform-cluster-example"
    #     key = "terraform.tfstate"
    #     region = "ap-south-1"
    #     encrypt = true

        
    #     dynamodb_table = "eks-cluster-table"
    # }
}