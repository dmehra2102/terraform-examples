resource "helm_release" "strimzi" {
    count = var.install_strimzi ? 1 : 0

    name = "strimzi-kafka-operator"
    repository          = "https://strimzi.io/charts/"
    chart               = "strimzi-kafka-operator"
    version             = var.strimzi_version
    namespace           = "kafka"
    create_namespace    = true

    values = [ 
        yamlencode({
            replicas = 2

            resources = {
                limits = {
                    cpu = "1000m"
                    memory = "512Mi"
                }
                requests = {
                    cpu    = "200m"
                    memory = "256Mi"
                }
            }

            logLevel = "INFO"
            watchNamespaces = ["kafka"]

            featureGates = "+UseKRaft,+KafkaNodePools,+UnidirectionalTopicOperator"

            env = [
                {
                    name  = "STRIMZI_FULL_RECONCILIATION_INTERVAL_MS"
                    value = "120000"
                },
                {
                    name  = "STRIMZI_OPERATION_TIMEOUT_MS"
                    value = "300000"
                }
            ]

        })
    ]

    depends_on = [module.eks]
}

resource "helm_release" "aws_lb_controller" {
    count = var.install_aws_lb_controller ? 1 : 0

    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    version    = "1.14.0"
    namespace  = "kube-system"

    values = [
        yamlencode({
            clusterName = module.eks.cluster_name
            serviceAccount = {
                create = true
                name   = "aws-load-balancer-controller"
                annotations = {
                    "eks.amazonaws.com/role-arn" = module.aws_lb_controller_irsa.iam_role_arn
                }
            }
            region      = var.aws_region
            vpcId       = module.vpc.vpc_id
            enableShield = false
            enableWaf    = false
            enableWafv2  = false
        })
    ]

    depends_on = [module.eks]
}

# Install Kubernetes Metrics Server
resource "helm_release" "metrics_server" {
    count = var.install_metrics_server ? 1 : 0

    name       = "metrics-server"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    chart      = "metrics-server"
    version    = "3.13.0"
    namespace  = "kube-system"

    values = [
        yamlencode({
            replicas = 2
            
            resources = {
                limits = {
                    cpu    = "100m"
                    memory = "200Mi"
                }
                requests = {
                    cpu    = "100m"
                    memory = "200Mi"
                }
            }

            podDisruptionBudget = {
                enabled      = true
                minAvailable = 1
            }

            affinity = {
                podAntiAffinity = {
                    preferredDuringSchedulingIgnoredDuringExecution = [
                        {
                            weight = 100
                            podAffinityTerm = {
                                labelSelector = {
                                    matchExpressions = [
                                        {
                                            key      = "app.kubernetes.io/name"
                                            operator = "In"
                                            values   = ["metrics-server"]
                                        }
                                    ]
                                }
                                topologyKey = "kubernetes.io/hostname"
                            }
                        }
                    ]
                }
            }
        })
    ]

    depends_on = [module.eks]
}

# Create namespace for Kafka resources
resource "kubernetes_namespace" "kafka" {
    metadata {
        name = "kafka"
        
        labels = {
        name        = "kafka"
        environment = var.environment
        }
    }

    depends_on = [module.eks]
}