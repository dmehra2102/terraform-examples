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
            version = ">= 1.0"
        }
    }

    backend "s3" {
        bucket = "terraform-cluster-example"
        key = "terraform.tfstate"
        region = "ap-south-1"
    }
}

provider "aws" {
    region = var.aws_region
    default_tags {
        tags = var.tags
    }
}

provider "kubernetes" {
    host = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.cluster_auth.token
}

provider "helm" {
    kubernetes = {
        host = aws_eks_cluster.main.endpoint
        cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
        token = data.aws_eks_cluster_auth.cluster_auth.token
    }
}

data "aws_eks_cluster" "main" {
    name = aws_eks_cluster.main.name
}

data "aws_eks_cluster_auth" "cluster_auth" {
    name = aws_eks_cluster.main.name
}