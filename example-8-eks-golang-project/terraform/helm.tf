resource "kubernetes_service_account_v1" "golang_app" {
    metadata {
        name = local.app_service_account_name
        namespace = local.app_namespace
        annotations = {
            "eks.amazonaws.com/role-arn"               = aws_iam_role.golang_app.arn
            "eks.amazonaws.com/sts-regional-endpoints" = "true"
        }
    }
}

resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
    metadata {
        name      = "aws-load-balancer-controller"
        namespace = "kube-system"
        annotations = {
            "eks.amazonaws.com/role-arn"               = aws_iam_role.alb_controller.arn
            "eks.amazonaws.com/sts-regional-endpoints" = "true"
        }
    }
}

resource "helm_release" "aws_load_balancer_controller" {
    name = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart = "aws-load-balancer-controller"
    namespace = "kube-system"

    set = [ 
        {
            name  = "clusterName"
            value = aws_eks_cluster.main.name
        },
        {
            name  = "serviceAccount.create"
            value = "false"
        },

        {
            name  = "serviceAccount.name"
            value = kubernetes_service_account_v1.aws_load_balancer_controller.metadata.0.name
        }
    ]
}