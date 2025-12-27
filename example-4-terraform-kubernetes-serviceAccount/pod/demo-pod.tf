resource "kubernetes_pod_v1" "demo_pod" {
    metadata {
        name = "pod-without-sa"
        labels = {
            app  = "irsa-demo"
        }
    }

    spec {
        service_account_name = var.service_account_name
        container {
            name = "aws-cli-container"
            image = "amazon/aws-cli"
            image_pull_policy = "IfNotPresent"
            args = [ "s3", "ls" ]
            port {
                container_port = 8080
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