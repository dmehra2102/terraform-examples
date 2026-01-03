# EKS Entry Access for Admin User and Roles

resource "aws_eks_access_entry" "admin_users" {
    for_each =  toset(var.admin_users) 

    cluster_name = aws_eks_cluster.main.name
    principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"
    kubernetes_groups = [ local.rbac_groups.admin ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "admin_roles" {
    for_each = toset(var.admin_roles)

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

# Eks Entry for Devloper User and Roles
resource "aws_eks_access_entry" "developer_users" {
    for_each = toset(var.developer_users)

    cluster_name = aws_eks_cluster.main.name
    principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"
    kubernetes_groups = [ local.rbac_groups.dev ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "developer_roles" {
    for_each = toset(var.developer_roles)

    cluster_name = aws_eks_cluster.main.name
    principal_arn = each.value
    kubernetes_groups = [ local.rbac_groups.dev ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "developer_role" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_developer_role.arn
    kubernetes_groups = [local.rbac_groups.dev]

    tags = local.common_tags
}

resource "aws_eks_access_policy_association" "developer_dev_edit_policy" {
    cluster_name = aws_eks_cluster.main.name
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    principal_arn = aws_iam_role.eks_developer_role.arn
    access_scope {
        type = "namespace"
        namespaces = [ local.namespaces.dev ]
    }
}

resource "aws_eks_access_policy_association" "developer_stag_edit_policy" {
    cluster_name = aws_eks_cluster.main.name
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    principal_arn = aws_iam_role.eks_developer_role.arn
    access_scope {
        type = "namespace"
        namespaces = [ local.namespaces.staging ]
    }
}

resource "aws_eks_access_policy_association" "developer_read_only_policy" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_developer_role.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    access_scope {
        type = "cluster"
    }
}

# Eks Entry for Devops User and Roles
resource "aws_eks_access_entry" "devops_users" {
    for_each = toset(var.devops_users)

    cluster_name = aws_eks_cluster.main.name
    principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"
    kubernetes_groups = [ local.rbac_groups.devops ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "devops_roles" {
    for_each =  toset(var.devops_roles)

    cluster_name = aws_eks_cluster.main.name
    principal_arn =each.value
    kubernetes_groups = [ local.rbac_groups.devops ]
    tags = local.common_tags
}

resource "aws_eks_access_entry" "devops_role" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_devops_role.arn
    kubernetes_groups = [local.rbac_groups.devops]
    tags = local.common_tags
}

resource "aws_eks_access_policy_association" "devops_edit_policy" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_devops_role.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    access_scope {
        type = "cluster"
    }
}

resource "aws_eks_access_policy_association" "devops_view_policy" {
    cluster_name = aws_eks_cluster.main.name
    principal_arn = aws_iam_role.eks_devops_role.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    access_scope {
        type = "namespace"
        namespaces = [local.namespaces.system]
    }
}

# Eks Entry for Reader User and Roles
resource "aws_eks_access_entry" "reader_users" {
    for_each = toset(var.reader_users)

    cluster_name      = aws_eks_cluster.main.name
    principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"
    kubernetes_groups = [local.rbac_groups.readers]

    tags = local.common_tags
}

resource "aws_eks_access_entry" "reader_roles" {
    for_each = toset(var.reader_roles)

    cluster_name      = aws_eks_cluster.main.name
    principal_arn     = each.value
    kubernetes_groups = [local.rbac_groups.readers]

    tags = local.common_tags
}

resource "aws_eks_access_entry" "reader_role" {
    cluster_name      = aws_eks_cluster.main.name
    principal_arn     = aws_iam_role.eks_reader_role.arn
    kubernetes_groups = [local.rbac_groups.readers]

    tags = local.common_tags
}

resource "aws_eks_access_policy_association" "reader_cluster_view" {
    cluster_name       = aws_eks_cluster.main.name
    policy_arn         = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    principal_arn      = aws_iam_role.eks_reader_role.arn
    access_scope {
        type = "cluster"
    }
}