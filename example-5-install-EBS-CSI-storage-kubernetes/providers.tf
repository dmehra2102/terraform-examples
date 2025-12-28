provider "aws" {
    region = "ap-south-1"
}

locals {
    cluster_ca_cert = base64decode(data.terraform_remote_state.eks_cluster_remote_state.outputs.eks_certificate_authority_data)
    cluster_endpoint = data.aws_eks_cluster.cluster.endpoint
    cluster_token = data.aws_eks_cluster_auth.cluster_auth.token
}

provider "kubernetes" {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_cert
    token                  = local.cluster_token
}

provider "helm" {
    kubernetes = {
        host                   = local.cluster_endpoint
        cluster_ca_certificate = local.cluster_ca_cert
        token                  = local.cluster_token
    }
}

provider "http" {}