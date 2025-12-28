resource "kubernetes_service_v1" "mysql_cluster_svc" {
    metadata {
        name = "mysql-cluster-svc"
    }
    spec {
        type = "ClusterIP"
        cluster_ip = "None"
        selector = {
            app = kubernetes_deployment_v1.mysql_deployment.spec.0.selector.0.match_labels.app
        }
        port {
            name = "http"
            port = "3306"
        }
    }
}