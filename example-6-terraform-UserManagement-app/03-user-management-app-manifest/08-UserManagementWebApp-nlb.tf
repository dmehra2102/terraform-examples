resource "kubernetes_service_v1" "user_app_nlb_svc" {
    metadata {
        name = "user-app-nlb-app"
        annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "lb"
        }
    }

    spec {
        type = "LoadBalancer"
        selector = {
            app = kubernetes_deployment_v1.usermgmt_webapp.spec.0.selector.0.match_labels.app
        }
        port {
            port = 80
            target_port = 8080
        }
    }
}