data "aws_eks_addon_version" "vpc_cni" {
    count = var.enable_vpc_cni ? 1 : 0
    addon_name = "vpc-cni"
    most_recent = true
    kubernetes_version = var.kubernetes_version
}

data "aws_eks_addon_version" "coredns" {
    addon_name = "coredns"
    most_recent = true
    kubernetes_version = var.kubernetes_version
}

data "aws_eks_addon_version" "kube_proxy" {
    addon_name = "kube-proxy"
    most_recent = true
    kubernetes_version = var.kubernetes_version
}

resource "aws_iam_role" "vpc_cni_role" {
    count       = var.enable_vpc_cni ? 1 : 0
    name_prefix = "${local.cluster_name}-vpc-cni-"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "VpcCniRole"
                Effect = "Allow"
                Action = "sts:AssumeRoleWithWebIdentity"
                Principal = {
                    Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
                }
                Condition = {
                    StringEquals = {
                        "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-node"
                    }
                }
            }
        ]
    })
}


resource "aws_iam_role_policy_attachment" "vpc_cni_policy" {
    count      = var.enable_vpc_cni ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.vpc_cni_role[0].name
}

resource "aws_eks_addon" "vpc_cni" {
    cluster_name = aws_eks_cluster.main.name
    addon_name = "vpc-cni"
    addon_version = data.aws_eks_addon_version.vpc_cni[0].version
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = aws_iam_role.vpc_cni_role[0].arn

    tags = local.common_tags

    depends_on = [ aws_eks_node_group.main ]
}

resource "aws_eks_addon" "coredns" {
    cluster_name = aws_eks_cluster.main.name
    addon_name = "coredns"
    addon_version = data.aws_eks_addon_version.coredns.version
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = null

    tags = local.common_tags

    depends_on = [ aws_eks_node_group.main ]
}

resource "aws_eks_addon" "kube_proxy" {
    cluster_name = aws_eks_cluster.main.name
    addon_name = "kube-proxy"
    addon_version = data.aws_eks_addon_version.kube_proxy.version
    resolve_conflicts_on_update = "OVERWRITE"

    tags = local.common_tags

    depends_on = [ aws_eks_node_group.main ]
}