locals {
    eks_cluster_master_subnet_ids = data.terraform_remote_state.my_vpc.outputs.private_subnet_ids
}

locals {
    iam_openid_connect_provider_url = aws_eks_cluster.my_eks_Cluster.identity[0].oidc[0].issuer
}