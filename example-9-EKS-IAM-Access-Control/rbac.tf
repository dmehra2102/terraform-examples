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
resource "kubernetes_cluster_role_v1" "name" {
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