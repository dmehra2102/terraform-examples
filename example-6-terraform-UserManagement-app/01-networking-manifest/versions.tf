terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }

    backend "s3" {
        bucket = "terraform-networking-example"
        key = "terraform.tfstate"
        region = "ap-south-1"

        use_lockfile = true
        encrypt = true
    }
}