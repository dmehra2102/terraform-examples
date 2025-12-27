resource "kubernetes_service_v1" "lb_service" {
    metadata {
        name = "myapp1-lb-service-clb"
    }
    spec {
        selector = {
            app = kubernetes_deployment_v1.demo_deployment.spec.0.template.0.metadata[0].labels.app
        }
        port {
            port        = 80
            target_port = 8080
        }

        type = "LoadBalancer"
    }
}