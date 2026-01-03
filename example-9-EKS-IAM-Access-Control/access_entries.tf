resource "aws_eks_access_entry" "admin_users" {
    for_each = var.admin_users

    cluster_name = aws_eks_cluster.main.name
    principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"
    kubernetes_groups = [ local.rbac_groups.admin ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "admin_roles" {
    for_each = var.admin_roles

    cluster_name = aws_eks_cluster.main.name
    principal_arn = each.value
    kubernetes_groups = [ local.rbac_groups.admin ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "admin_role" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_admin_role.arn
    kubernetes_groups = [ local.rbac_groups.admin ]

    tags = local.common_tags
}

resource "aws_eks_access_policy_association" "admin_policy" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_admin_role.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope {
        type = "cluster"
    }
}