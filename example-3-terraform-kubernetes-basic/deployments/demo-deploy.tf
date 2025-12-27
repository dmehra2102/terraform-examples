resource "kubernetes_deployment_v1" "demo_deployment" {
    metadata {
        name = "dmeo-deployment"
        labels = {
            Environment = "development"
            ResourceType = "apps"
        }
    }

    spec {
        replicas = 2
        min_ready_seconds = 10
        strategy {
            type = "RollingUpdate"
            rolling_update {
                max_unavailable = 1
                max_surge = 1
            }
        }
        selector {
            match_labels = {
                app = "demo-deployment"
            }
        }
        template {
            metadata {
                labels = {
                    app = "demo-deployment"
                }
            }
            spec {
                container {
                    name = "http-echo-container"
                    image = "hashicorp/http-echo:latest"
                    image_pull_policy = "IfNotPresent"
                    args = ["-text=Hello from Kubernetes!", "-listen=:8080"]
                    port {
                        container_port = "8080"
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
    }
}