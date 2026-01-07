variable "aws_region" {
    type = string
    description = "AWS region for all resources"
}

variable "cluster_name" {
    type = string
    description = "EKS cluster name for provider configuration."
}

provider "aws" {
    region = var.aws_region
}

provider "kubernetes" {
    host = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
    kubernetes = {
        host = data.aws_eks_cluster.this.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
        token = data.aws_eks_cluster_auth.this.token
    }
}

data "aws_eks_cluster" "this" {
    name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
    name = var.cluster_name
}