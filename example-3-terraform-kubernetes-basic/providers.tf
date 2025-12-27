provider "aws" {
    region = "ap-south-1"
}

data "aws_eks_cluster" "cluster"{
    name = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
    name = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_id
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_cluster.outputs.eks_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster_auth.token
}