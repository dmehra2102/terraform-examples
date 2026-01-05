locals {
    kube_system_sa_name = "aws-load-balancer-controller"
    kube_system_sa_ns   = "kube-system"
}

# ---------------------------
# VPC (community module)
# ---------------------------
module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "6.5.1"

    name = "prod-vpc"
    cidr = "10.0.0.0/16"

    azs = data.aws_availability_zones.available.names

    public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]
    private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true
}


# -------------------------------
# EKS Cluster (community module)
# -------------------------------
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "21.10.1"

    name = var.cluster_name
    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id
    kubernetes_version = "1.34"

    eks_managed_node_groups = {
        ng = {
            desired_size = var.node_desired_capacity
            instance_types = [var.node_instance_type]
        }
    }

    enable_irsa = true
}

# ---------------------------------------------------
# OIDC provider (The ARN of the OIDC Provider if enable_irsa = true in eks module)
# ---------------------------------------------------
data "aws_iam_openid_connect_provider" "current" {
    arn = try(module.eks.oidc_provider_arn, "")
}

# ---------------------------------------
# IAM Role for ALB Controller (IRSA)
# ---------------------------------------
resource "aws_iam_role" "alb_controller" {
    name = "${var.cluster_name}-alb-controller-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "ELBContollerAllow"
                Effect = "Allow"
                Action = "sts:AssumeRoleWithWebIdentity"
                Principal = {
                    Federated = "${module.eks.oidc_provider_arn}"
                }
                Condition = {
                    StringEquals = {
                        "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"  : "system:serviceaccount:${local.kube_system_sa_ns}:${local.kube_system_sa_name}"
                    }
                }
            }
        ]
    })

    tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
}

resource "aws_iam_policy" "elb_controller_iam_policy" {
    name = "elb-controller-iam-policy"
    path = "/"

    policy = local.aws_lb_policy
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
    role = aws_iam_role.alb_controller.name
    policy_arn = aws_iam_policy.elb_controller_iam_policy.arn
}

# ----------------------------------------
# Kubernetes ServiceAccount for ALB controller (do not create role annotation here; we will annotate with IAM role ARN)
# ----------------------------------------
resource "kubernetes_service_account_v1" "alb_controller_sa" {
    metadata {
        name = local.kube_system_sa_name
        namespace = local.kube_system_sa_ns
        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
        }
    }
}

# ------------------------------------------
# Helm release: AWS Load Balancer Controller
# ------------------------------------------
resource "helm_release" "aws_lb_controller" {
    name = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = local.kube_system_sa_ns
    create_namespace = false
    version = "1.14.0"

    values = [ 
        yamlencode({
            clusterName = module.eks.cluster_id
            serviceAccount = {
                create  = false
                name    = kubernetes_service_account_v1.alb_controller_sa.metadata[0].name
            }
            region = var.region
            vpcId  = module.vpc.vpc_id
        })
    ]

    depends_on = [ 
        kubernetes_service_account_v1.alb_controller_sa,
        aws_iam_role_policy_attachment.alb_controller_policy
    ]
}
