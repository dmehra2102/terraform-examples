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
    version    = "1.11.1"
    namespace  = "kube-system"

    set {
        name  = "clusterName"
        value = module.eks.cluster_name
    }

    set {
        name  = "serviceAccount.create"
        value = "true"
    }

    set {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
    }

    set {
        name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = module.aws_lb_controller_irsa.iam_role_arn
    }

    set {
        name  = "region"
        value = var.aws_region
    }

    set {
        name  = "vpcId"
        value = module.vpc.vpc_id
    }

    set {
        name  = "enableShield"
        value = "false"
    }

    set {
        name  = "enableWaf"
        value = "false"
    }

    set {
        name  = "enableWafv2"
        value = "false"
    }

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