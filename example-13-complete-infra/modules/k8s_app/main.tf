resource "kubernetes_namespace_v1" "app" {
    metadata {
        name = var.namespace
        labels = {
            "pod-security.kubernetes.io/enforce" = var.pod_security_level
        }
    }
}

# NetworkPolicy: default deny, allow only from ingress controller namespace
resource "kubernetes_network_policy_v1" "default_deny" {
    metadata {
        name      = "default-deny"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
    }

    spec {
        pod_selector {}
        policy_types = ["Ingress", "Egress"]
    }
}

resource "kubernetes_network_policy_v1" "allow_ingress_from_alb_ns" {
    metadata {
        name = "allow-ingress-from-alb-ns"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
    }

    spec {
        pod_selector {}
        policy_types = [ "Ingress", "Egress" ]
        ingress {
            from {
                namespace_selector {
                    match_labels = {
                        "kubernetes.io/metadata.name" = var.ingress_controller_namespace                      
                    }
                }
            }
        }
        egress {
            to {
                pod_selector {}
            }
        }
    }
}

# RBAC
resource "kubernetes_role_v1" "app_reader" {
    metadata {
        name = "app-reader"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
    }

    rule {
        api_groups = [ "" ]
        resources  = ["pods", "services"]
        verbs      = ["get", "list", "watch"]
    }
}

resource "kubernetes_service_account_v1" "app" {
    metadata {
        name      = "app-sa"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
    }
}

resource "kubernetes_role_binding_v1" "app_reader_binding" {
    metadata {
        name = "kube-app-binding"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
    }

    subject {
        kind = "ServiceAccount"
        name = kubernetes_service_account_v1.app.metadata[0].name
        namespace = kubernetes_namespace_v1.app.metadata[0].name
    }

    role_ref {
        kind = "Role"
        api_group = "rbac.authorization.k8s.io"
        name = kubernetes_role_v1.app_reader.metadata[0].name
    }
}