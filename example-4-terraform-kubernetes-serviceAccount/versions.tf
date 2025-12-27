terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.27.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "3.0.1"
        }
    }

    backend "s3" {
        bucket = "terraform-kubernetes-example"
        key = "terraform.tfstate"
        region = "ap-south-1"

        encrypt = true
        use_lockfile = true
    }
}