locals {
    eks_cluster_subnet_ids = data.terraform_remote_state.aws_networking.outputs.private_subnet_ids
    eks_cluster_worker_node_subnet_ids = data.terraform_remote_state.aws_networking.outputs.private_subnet_ids
}