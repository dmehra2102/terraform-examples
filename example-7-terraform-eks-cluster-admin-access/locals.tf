locals {
    eks_cluster_master_subnet_ids = data.terraform_remote_state.my_vpc.outputs.private_subnet_ids
}