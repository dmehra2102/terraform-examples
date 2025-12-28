locals {
    eks_cluster_subnet_ids = data.terraform_remote_state.aws_networking.outputs.private_subnet_ids
}