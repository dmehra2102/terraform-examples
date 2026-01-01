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

    #  S3 bucket must already exist ( Terraform will not create it from this backend block)
    backend "s3" {
        bucket = "terraform-cluster-example"
        key = "golang-app/terraform.tfstate"
        region = "ap-south-1"
        encrypt = true
        dynamodb_table = "golang-app-table"
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

data "aws_eks_cluster_auth" "main" {
    name = aws_eks_cluster.main.name
}

provider "kubernetes" {
    host = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
    kubernetes = {
        host = aws_eks_cluster.main.endpoint
        cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
        token = data.aws_eks_cluster_auth.main.token
    }
}
