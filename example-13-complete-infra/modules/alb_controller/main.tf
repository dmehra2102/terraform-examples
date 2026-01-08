data "http" "aws_lb_policy" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

    # Optional request headers
    request_headers = {
        Accept = "application/json"
    }
}

locals {
    aws_lb_policy = data.http.aws_lb_policy.response_body
}

data "aws_iam_openid_connect_provider" "oidc" {
    arn = var.oidc_provider_arn
}

module "irsa_alb" {
    source = "../irsa"

    namespace               = var.namespace
    name_prefix             = var.name_prefix
    oidc_provider_arn       = var.oidc_provider_arn
    service_account_name    = var.service_account_name
    inline_policy_json      = data.aws_iam_policy_document.alb.json
    oidc_provider_url       = replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")
    tags                    = var.tags
}

# Namespace and service account
resource "kubernetes_namespace_v1" "alb" {
    metadata {
        name = var.namespace
        labels = {
            "app.kubernetes.io/name" = "aws-load-balancer-controller"
        }
    }
}

resource "kubernetes_service_account_v1" "alb" {
    metadata {
        name = var.service_account_name
        namespace = kubernetes_namespace_v1.alb.metadata[0].name
        annotations = {
            "eks.amazonaws.com/role-arn" = module.irsa_alb.role_arn
        }
        labels = {
            "app/kubernetes.io/name" = "aws-load-balancer-controller"
        }
    }
}

resource "helm_release" "alb" {
    name        = "aws-load-balancer-controller"
    namespace   = kubernetes_namespace_v1.alb.metadata[0].name
    repository  = "https://aws.github.io/eks-charts"
    chart       = "aws-load-balancer-controller"
    version     = var.chart_version

    values = [
        yamlencode({
            clusterName      = var.cluster_name
            serviceAccount   = {
                create  = false
                name    = var.service_account_name
            }
            region          = var.region
            vpcId           = var.vpc_id
            defaultTags     = var.tags
            enableShield    = var.enable_shield
            enableWaf       = var.enable_waf
            enableWafv2     = var.enable_wafv2
        })
    ]

    depends_on = [kubernetes_service_account_v1.alb]
}