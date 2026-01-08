output "namespace" {
    value       = kubernetes_namespace.alb.metadata[0].name
    description = "Namespace of ALB controller."
}
