provider "aws" {
    region = "ap-south-1"
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_cluster_remote_state.outputs.eks_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster_auth.token
}

provider "http" {}