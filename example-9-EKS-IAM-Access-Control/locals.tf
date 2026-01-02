locals {
    cluster_name = var.cluster_name != "" ? var.cluster_name : "${var.project_name}-${var.environment}-eks"
    common_tags = merge(var.tags,{
        Environment = var.environment
        Project     = var.project_name
        ManagedBy   = "Terraform"
        CreatedAt   = timestamp()
    })

    rbac_groups = {
        admin    = "system:masters"
        devops   = "devops"
        dev      = "developers"
        readers  = "readers"
    }

    # Kubernetes namespaces
    namespaces = {
        dev     = "dev"
        staging = "staging"
        prod    = "prod"
        system  = "kube-system"
    }

    access_scrops = {
        cluster_wide = {
            type      = "cluster"
            namespace = null
        }
        dev_namespace = {
            type      = "namespace"
            namespace = local.namespaces.dev
        }
        staging_namespace = {
            type      = "namespace"
            namespace = local.namespaces.staging
        }
    }

    cluster_log_types = var.enable_logging ? [
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
    ] : []

}