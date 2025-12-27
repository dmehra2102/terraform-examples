data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
    url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
    client_id_list = ["sts.${data.aws_partition.current.dns_suffix}"]
    thumbprint_list = [var.eks_oidc_root_ca_thumbprint]

    tags = {
        Name = "${var.eks_cluster_name}-irsa-demo"
    }
}

locals {
    aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", aws_iam_openid_connect_provider.oidc_provider.arn), 1)
}