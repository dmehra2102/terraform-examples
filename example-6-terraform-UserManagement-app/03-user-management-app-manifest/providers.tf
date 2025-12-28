provider "aws" {
    region = "ap-south-1"
}

data "aws_eks_cluster" "my_cluster" {
    name = data.terraform_remote_state.eks_cluster.outputs.cluster_id
}

data "aws_eks_cluster_auth" "my_cluster_auth" {
    name = data.terraform_remote_state.eks_cluster.outputs.cluster_id
}

provider "kubernetes" {
    host = data.terraform_remote_state.eks_cluster.outputs.cluster_api_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_cluster.outputs.cluster_certificate_authority)
    token = data.aws_eks_cluster_auth.my_cluster_auth.token
}