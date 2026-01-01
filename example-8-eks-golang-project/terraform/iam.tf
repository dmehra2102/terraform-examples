locals {
    eks_cluster_provider_url = aws_eks_cluster.main.identity[0].oidc[0].issuer
    app_service_account_name = "golang-app-sa"
    app_namespace            = "default"
}

data "tls_certificate" "eks" {
    url = local.eks_cluster_provider_url
}

data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "eks" {
    url = local.eks_cluster_provider_url
    client_id_list = ["sts.${data.aws_partition.current.dns_suffix}"]
    thumbprint_list = [ data.tls_certificate.eks.certificates.sha1_fingerprint ]
}

# Role For Golang-App to access s3 and IAM resources
resource "aws_iam_role" "golang_app" {
    name = "${var.project_name}-golang-app-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "GolangAppRole"
                Action = "sts:AssumeRoleWithWebIdentity"
                Effect = "Allow"
                Principal = {
                    Federated = aws_iam_openid_connect_provider.eks.arn
                }
                Condition = {
                    StringEquals = {
                        "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:${local.app_namespace}:${local.app_service_account_name}"
                        "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                    }
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "golang_app_policy" {
    name = "${var.project_name}-golang-app-policy"
    role = aws_iam_role.golang_app.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "S3BucketAccess"
                Effect = "Allow"
                Action = [
                    "s3:Get*",
                    "s3:List*",
                    "s3:Describe*"
                ]
                Resource = "*"
            },
            {
                Sid = "IAMAcess"
                Effect = "Allow"
                Action = [
                    "iam:ListUsers",
                    "iam:GetUser",
                    "iam:ListRoles",
                    "iam:GetRole",
                    "iam:ListRolePolicies",
                    "iam:GetRolePolicy"
                ]
                Resource = "*"
            }
        ]
    })
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller" {
    name = "${var.project_name}-alb-controller"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "EC2Access"
                Effect = "Allow"
                Action = "sts:AssumeRoleWithWebIdentity"
                Principal = {
                    Federated = aws_iam_openid_connect_provider.arn
                }
                Condition  = {
                    StringEquals = {
                        "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
                        "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                    }
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
    role = aws_iam_role.alb_controller.name
    policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}