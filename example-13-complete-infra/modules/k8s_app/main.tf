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

# Deployment (Dummy)
resource "kubernetes_deployment_v1" "app" {
    metadata {
        name = var.app_name
        namespace = kubernetes_namespace_v1.app.metadata[0].name
        labels = {
            "app" = var.app_name
        }
    }
    spec {
        replicas = var.replicas
        selector {
            match_labels = {
            "app" = var.app_name
            }
        }
        template {
            metadata {
            labels = {
                "app" = var.app_name
            }
            }
            spec {
                service_account_name = kubernetes_service_account_v1.app.metadata[0].name
                container {
                    name  = var.app_name
                    image = var.image

                    port {
                        container_port = 8080
                    }

                    resources {
                        limits = {
                        cpu    = "200m"
                        memory = "256Mi"
                        }
                        requests = {
                        cpu    = "100m"
                        memory = "128Mi"
                        }
                    }

                    liveness_probe {
                        http_get {
                            path = "/healthz"
                            port = 8080
                        }
                        initial_delay_seconds = 5
                        period_seconds = 10
                    }

                    readiness_probe {
                        http_get {
                            path = "/readyz"
                            port = 8080
                        }
                        initial_delay_seconds = 5
                        period_seconds        = 10
                    }
                }

                security_context {
                    run_as_non_root = true
                    run_as_user = 1000
                    fs_group = 2000
                }
            }
        }
    }
}

resource "kubernetes_service_v1" "app" {
    metadata {
        name = "${var.app_name}-svc"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
        labels = {
            "app" = var.app_name
        }
    }

    spec {
        selector = {
            "app" = var.app_name
        }

        port {
            name = "http"
            port = 80
            node_port = 8080
        }

        type = "NodePort"
    }
}

# Ingress via ALB Controller
resource "kubernetes_ingress_v1" "app" {
    metadata {
        name      = "${var.app_name}-ing"
        namespace = kubernetes_namespace_v1.app.metadata[0].name
        annotations = {
            "kubernetes.io/ingress.class"                 = "alb"
            "alb.ingress.kubernetes.io/scheme"            = var.alb_scheme
            "alb.ingress.kubernetes.io/target-type"       = "ip"
            "alb.ingress.kubernetes.io/listen-ports"      = "[{\"HTTP\":80}]"
            "alb.ingress.kubernetes.io/healthcheck-path"  = "/readyz"
            "alb.ingress.kubernetes.io/group.name"        = var.alb_group_name
            "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=60"
            "alb.ingress.kubernetes.io/subnets"           = join(",", var.public_subnet_ids)
            "alb.ingress.kubernetes.io/security-groups"   = var.alb_sg_id
        }
    }

    spec {
        rule {
            http {
                path {
                    path      = "/"
                    path_type = "Prefix"

                    backend {
                        service {
                            name = kubernetes_service_v1.app.metadata[0].name
                        port {
                            number = 80
                        }
                    }
                }
                }
            }
        }
    }
}