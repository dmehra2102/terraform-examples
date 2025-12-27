resource "kubernetes_pod_v1" "basic_pod" {
    metadata {
        name = "basic-demo-pod"
        labels = {
            Environment = "development"
            ResourceType = "Core"
        }
    }

    spec {
        container {
            name = "nginx-container-1"
            image = "nginx:1.27-alpine"
            image_pull_policy = "IfNotPresent"
            port {
                container_port = "80"
                protocol = "TCP"
                name = "http"
            }
            resources {
                requests = {
                    cpu = "100m"
                    memory = "128Mi"
                }
                limits = {
                    cpu = "500m"
                    memory = "256Mi"
                }
            }
        }
    }
}