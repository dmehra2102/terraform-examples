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