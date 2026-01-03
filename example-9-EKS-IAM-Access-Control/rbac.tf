# Create Namespaces

resource "kubernetes_namespace_v1" "dev" {
    metadata {
        name = local.namespaces.dev
        labels = {
            "environment" = "development"
            "managed-by"  = "terraform"
        }
    }

    depends_on = [ aws_eks_cluster.main ]
}

resource "kubernetes_namespace_v1" "staging" {
    metadata {
        name = local.namespaces.staging
        labels = {
            "environment" = "staging"
            "managed-by"  = "terraform"
        }
    }

    depends_on = [ aws_eks_cluster.main ]
}

resource "kubernetes_namespace_v1" "prod" {
    metadata {
        name = local.namespaces.prod
        labels = {
            "environment" = "production"
            "managed-by"  = "terraform"
        }
    }

    depends_on = [ aws_eks_cluster.main ]
}

# Admin ClusterRole
resource "kubernetes_cluster_role_v1" "admin" {
    metadata {
        name = "${local.rbac_groups.admin}-role"
    }

    rule {
        api_groups = [ "*" ]
        resources = ["*"]
        verbs = ["*"]
    }

    depends_on = [ aws_eks_cluster.main ]
}

# Developer ClusterRole
resource "kubernetes_cluster_role_v1" "developer" {
    metadata {
        name = "${local.rbac_groups.dev}-role"
    }

    rule {
        api_groups = ["apps"]
        resources  = ["deployments", "statefulsets", "daemonsets", "replicasets"]
        verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    }

    rule {
        api_groups = ["batch"]
        resources  = ["jobs", "cronjobs"]
        verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    }

    rule {
        api_groups = [""]
        resources  = ["pods/logs"]
        verbs      = ["get", "list", "watch"]
    }

    rule {
        api_groups = [""]
        resources  = ["pods", "services", "configmaps", "secrets"]
        verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    }

    rule {
        api_groups = [""]
        resources  = ["namespaces"]
        verbs      = ["get", "list"]
    }

    depends_on = [ aws_eks_cluster.main ]
}

# Reader ClusterRole
resource "kubernetes_cluster_role_v1" "readers" {
    metadata {
        name = "${local.rbac_groups.readers}-role"
    }

    rule {
        api_groups = ["*"]
        resources  = ["*"]
        verbs      = ["get", "list", "watch"]
    }

    rule {
        api_groups = [""]
        resources  = ["pods/logs"]
        verbs      = ["get", "list"]
    }

    depends_on = [aws_eks_cluster.main]
}

# DevOps ClusterRole
resource "kubernetes_cluster_role_v1" "devops" {
    metadata {
        name = "${local.rbac_groups.devops}-role"
    }

    rule {
        api_groups = ["*"]
        resources  = ["*"]
        verbs      = ["*"]
    }

    rule {
        non_resource_urls = ["/metrics", "/logs"]
        verbs             = ["get"]
    }

    depends_on = [aws_eks_cluster.main]
}

# ClusterRoleBinding
resource "kubernetes_cluster_role_binding_v1" "admin" {
    metadata {
        name = "${local.rbac_groups.admin}-binding"
    }

    role_ref {
        kind = "ClusterRole"
        api_group = "rbac.authorization.k8s.io"
        name = kubernetes_cluster_role_v1.admin.metadata.0.name
    }

    subject {
        kind = "Group"
        name = local.rbac_groups.admin
    }
    
    depends_on = [ aws_eks_cluster.main ]
}

resource "kubernetes_cluster_role_binding_v1" "dev" {
    metadata {
        name = "${local.rbac_groups.dev}-binding"
    }

    role_ref {
        kind = "ClusterRole"
        api_group = "rbac.authorization.k8s.io"
        name = kubernetes_cluster_role_v1.developer.metadata.0.name
    }

    subject {
        kind = "Group"
        name = local.rbac_groups.dev
    }
    
    depends_on = [ aws_eks_cluster.main ]
}

resource "kubernetes_cluster_role_binding_v1" "devops" {
    metadata {
        name = "${local.rbac_groups.devops}-binding"
    }

    role_ref {
        kind = "ClusterRole"
        api_group = "rbac.authorization.k8s.io"
        name = kubernetes_cluster_role_v1.devops.metadata.0.name
    }

    subject {
        kind = "Group"
        name = local.rbac_groups.devops
    }
    
    depends_on = [ aws_eks_cluster.main ]
}

resource "kubernetes_cluster_role_binding_v1" "readers" {
    metadata {
        name = "${local.rbac_groups.readers}-binding"
    }

    role_ref {
        kind = "ClusterRole"
        api_group = "rbac.authorization.k8s.io"
        name = kubernetes_cluster_role_v1.readers.metadata.0.name
    }

    subject {
        kind = "Group"
        name = local.rbac_groups.readers
    }
    
    depends_on = [ aws_eks_cluster.main ]
}

# Namespace Specific Developer Role
resource "kubernetes_role_v1" "dev_ns" {
    metadata {
        name      = "developers-role"
        namespace = kubernetes_namespace_v1.dev.metadata[0].name
    }

    rule {
        api_groups = ["apps"]
        resources  = ["deployments", "statefulsets", "daemonsets"]
        verbs      = ["*"]
    }

    rule {
        api_groups = [""]
        resources  = ["pods", "pods/log", "services"]
        verbs      = ["*"]
    }

    rule {
        api_groups = [""]
        resources  = ["configmaps", "secrets"]
        verbs      = ["get", "list", "watch"]
    }

    depends_on = [kubernetes_namespace.dev]
}

resource "kubernetes_role_binding" "dev_ns" {
    metadata {
        name      = "dev-binding"
        namespace = kubernetes_namespace_v1.dev.metadata[0].name
    }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = kubernetes_role_v1.dev_ns.metadata[0].name
    }

    subject {
        kind = "Group"
        name = local.rbac_groups.dev
    }

    depends_on = [kubernetes_role_v1.dev_ns]
}

resource "kubernetes_role_v1" "stag_ns" {
    metadata {
        name      = "stag-developers-role"
        namespace = kubernetes_namespace_v1.staging.metadata[0].name
    }

    rule {
        api_groups = ["apps"]
        resources  = ["deployments", "statefulsets", "daemonsets"]
        verbs      = ["*"]
    }

    rule {
        api_groups = [""]
        resources  = ["pods", "pods/log", "services"]
        verbs      = ["*"]
    }

    rule {
        api_groups = [""]
        resources  = ["configmaps", "secrets"]
        verbs      = ["get", "list", "watch"]
    }

    depends_on = [kubernetes_namespace_v1.staging]
}

resource "kubernetes_role_binding" "stag_ns" {
    metadata {
        name      = "stag-binding"
        namespace = kubernetes_namespace_v1.staging.metadata.0.name
    }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = kubernetes_role_v1.dev_ns.metadata[0].name
    }

    subject {
        kind = "Group"
        name = local.rbac_groups.dev
    }

    depends_on = [kubernetes_role_v1.stag_ns]
}