terraform {
    required_version = ">= 1.4"
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
        http = {
            source = "hashicorp/http"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "ap-south-1"
}

provider "kubernetes" {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
    kubernetes = {
        host = module.eks.cluster_endpoint
        cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
        token = data.aws_eks_cluster_auth.cluster.token
    }
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
    state = "available"
    filter {
        name   = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}