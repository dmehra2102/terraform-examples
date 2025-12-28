terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
        http = {
            source = "hashicorp/http"
            version = ">= 3.0"
        }
    }

    backend "s3" {
        bucket = "terraform-cluster-example"
        key = "terraform.tfstate"
        region = "ap-south-1"

        use_lockfile = true
        encrypt = true
    }
}