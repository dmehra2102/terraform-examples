data "terraform_remote_state" "eks_cluster_remote_state" {
    backend = "s3"

    config = {
        bucket = "terraform-networking-example"
        key = "terraform.tfstate"
        region = "ap-south-1"
    }
}


data "aws_eks_cluster" "cluster" {
    name = data.terraform_remote_state.eks_cluster_remote_state.outputs.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
    name = data.terraform_remote_state.eks_cluster_remote_state.outputs.eks_cluster_id
}