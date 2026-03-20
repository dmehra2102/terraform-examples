# =============================================================================
# EKS Cluster + Managed Node Groups + Core Add-ons + NGINX Ingress
# =============================================================================
locals {
    node_group_defaults = {
        ami_type        = "AL2_x86_64"
        disk_size       = 100
        capacity_type   = "ON_DEMAND"
    }
}

# ========================================================
# IAM: EKS Cluster Role
# ========================================================
resource "aws_iam_role" "cluster" {
    name = "${var.name_prefix}-eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action  = "sts:AssumeRole"
            Effect  = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
    role        = aws_iam_role.cluster.name
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_resource" {
    role        = aws_iam_role.cluster.name
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# ========================================================
# SECURITY GROUPS
# ========================================================
resource "aws_security_group" "cluster" {
    name = "${var.name_prefix}-sg-eks-cluster"
    description = "EKS cluster control plane security group"
    vpc_id = var.vpc_id

    egress {
        description = "Allow all outbound"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = {
        Name = "${var.name_prefix}-sg-eks-cluster"
    }
}

# Node SG — nodes communicate with each other and control plane
resource "aws_security_group" "nodes" {
    name        = "${var.name_prefix}-sg-eks-nodes"
    description = "EKS worker node security group"
    vpc_id      = var.vpc_id

    ingress {
        description = "Node-to-node all traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        self        = true
    }

    ingress {
        description = "Control plane to nodes (kubelet)"
        from_port   = 10250
        to_port     = 10250
        protocol    = "tcp"
        security_groups = [ aws_security_group.cluster.id ]
    }

    # Allow pods to receive traffic from ALB/NLB
    ingress {
        description = "HTTPS from VPC (load balancers, webhooks)"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
    }

    ingress {
        description = "HTTP from VPC (load balancers)"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
    }

    egress {
        description = "Allow all outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.name_prefix}-sg-eks-nodes"
        # Karpenter needs this tag to find the node SG
        "karpenter.sh/discovery" = var.cluster_name
    }
}

resource "aws_security_group_rule" "nodes_to_cluster_443" {
    description              = "Nodes to control plane HTTPS"
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nodes.id
    security_group_id        = aws_security_group.cluster.id
}

# =============================================================================
# EKS CLUSTER
# =============================================================================
resource "aws_eks_cluster" "main" {
    name = var.cluster_name
    version = var.cluster_version
    role_arn = aws_iam_role.cluster.arn

    vpc_config {
        subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
        security_group_ids = [ aws_security_group.cluster.id ]
        endpoint_private_access = true
        endpoint_public_access = var.cluster_endpoint_public_access
        public_access_cidrs = var.cluster_endpoint_public_access_cidrs
    }

    encryption_config {
        provider {
            key_arn = var.kms_key_arn
        }
        resources = [ "secrets" ]
    }

    # Enable all control-plane log types to CloudWatch
    enabled_cluster_log_types = [
        "api", "audit", "authenticator", "controllerManager", "scheduler"
    ]

    kubernetes_network_config {
        ip_family = "ipv4"
        service_ipv4_cidr = "172.20.0.0/16"
    }

    tags = { Name = var.cluster_name }

    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy,
        aws_iam_role_policy_attachment.cluster_vpc_resource,
    ]

    # Ignore version changes if managed externally (upgrade via separate workflow)
    lifecycle {
        ignore_changes = [kubernetes_network_config]
    }
}

# =============================================================================
# OIDC PROVIDER (required for IRSA)
# =============================================================================
data "tls_certificate" "eks_oidc" {
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
    url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# ==========================================================================
# IAM: Managed Node Group Role
# ==========================================================================
resource "aws_iam_role" "node_group" {
    name = "${var.name_prefix}-eks-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
    role       = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
    role       = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
    role       = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ssm_policy" {
    role       = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# =============================================================================
# MANAGED NODE GROUPS
# =============================================================================
resource "aws_eks_node_group" "main" {
    for_each = var.node_groups

    cluster_name = aws_eks_cluster.main.name
    node_group_name = "${var.name_prefix}-ng-${each.key}"
    node_role_arn = aws_iam_role.node_group.arn
    subnet_ids = var.private_subnet_ids
    instance_types  = each.value.instance_types
    capacity_type   = each.value.capacity_type
    disk_size       = each.value.disk_size_gb

    scaling_config {
        min_size     = each.value.min_size
        max_size     = each.value.max_size
        desired_size = each.value.desired_size
    }

    update_config {
        max_unavailable_percentage = 25
    }

    labels = merge(
        each.value.labels,
        {
            "node.kubernetes.io/nodegroup" = each.key
        }
    )

    dynamic "taint" {
        for_each = each.value.taints
        content {
            key =  taint.value.key
            value = taint.value.value
            effect = taint.value.effect
        }
    }

    tags = {
        Name = "${var.name_prefix}-ng-${each.key}"
        # Required for Karpenter to cordon nodes on scale-down
        "karpenter.sh/discovery" = var.cluster_name
    }

    depends_on = [
        aws_iam_role_policy_attachment.node_worker_policy,
        aws_iam_role_policy_attachment.node_ecr_policy,
        aws_iam_role_policy_attachment.node_cni_policy,
    ]

    lifecycle {
        ignore_changes = [scaling_config[0].desired_size]
    }
}

# =========================================================
# EKS ADD-ONS (managed, auto-patched by AWS)
# =========================================================
resource "aws_eks_addon" "vpc_cni" {
    cluster_name = var.cluster_name
    addon_name = "vpc-cni"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = aws_iam_role.vpc_cni_irsa.arn

    configuration_values = jsonencode({
        env = {
            ENABLE_PREFIX_DELEGATION = "true"
            WARM_PREFIX_TARGET       = "1"
        }
    })

    tags = { 
        Name = "${var.name_prefix}-addon-vpc-cni" 
    }
    depends_on = [aws_eks_node_group.main]
}

resource "aws_iam_role" "vpc_cni_irsa" {
    name = "${var.name_prefix}-irsa-vpc-cni"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                federated = aws_iam_openid_connect_provider.eks.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-node"
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "vpc_cni_irsa" {
    role       = aws_iam_role.vpc_cni_irsa.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_addon" "coredns" {
    cluster_name             = aws_eks_cluster.main.name
    addon_name               = "coredns"
    resolve_conflicts_on_update = "OVERWRITE"
    tags = { Name = "${var.name_prefix}-addon-coredns" }
    depends_on = [aws_eks_addon.vpc_cni]
}

resource "aws_eks_addon" "kube_proxy" {
    cluster_name             = aws_eks_cluster.main.name
    addon_name               = "kube-proxy"
    resolve_conflicts_on_update = "OVERWRITE"
    tags = { Name = "${var.name_prefix}-addon-kube-proxy" }
    depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "ebs_csi" {
    cluster_name             = aws_eks_cluster.main.name
    addon_name               = "aws-ebs-csi-driver"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn
    tags = { 
        Name = "${var.name_prefix}-addon-ebs-csi" 
    }
    depends_on = [aws_eks_node_group.main]
}

resource "aws_iam_role" "ebs_csi_irsa" {
    name = "${var.name_prefix}-irsa-ebs-csi"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { 
                Federated = aws_iam_openid_connect_provider.eks.arn 
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_irsa" {
    role       = aws_iam_role.ebs_csi_irsa.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# =============================================================================
# HELM: NGINX Ingress Controller
# =============================================================================
resource "kubernetes_namespace_v1" "ingress_nginx" {
    metadata {
        name = "ingress-nginx"
        labels = {
            "app.kubernetes.io/managed-by" = "Terraform"
        }
    }
    depends_on = [aws_eks_addon.coredns]
}

resource "helm_release" "nginx_ingress" {
    name       = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart      = "ingress-nginx"
    version    = "4.10.1"
    namespace  = kubernetes_namespace_v1.ingress_nginx.metadata[0].name
    atomic     = true
    timeout    = 600

    values = [file("${path.module}/../../helm-values/nginx-ingress.yaml")]
    set = [ 
        {
            name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
            value = "external"
        },
        {
            name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
            value = "ip"
        },
        {
            name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
            value = "internet-facing"
        }
    ]

    depends_on = [aws_eks_node_group.main]
}

# =====================================================
# HELM: External Secrets Operator
# =====================================================
resource "kubernetes_namespace_v1" "external_secrets" {
    metadata {
        name = "external-secrets"
        labels = { 
            "app.kubernetes.io/managed-by" = "Terraform"
        }
    }
    depends_on = [ aws_eks_addon.coredns ]
}

resource "helm_release" "external_secrets" {
    name       = "external-secrets"
    repository = "https://charts.external-secrets.io"
    chart      = "external-secrets"
    version    = "0.9.16"
    namespace  = kubernetes_namespace_v1.external_secrets.metadata[0].name
    atomic     = true
    timeout    = 300

    set = [{
        name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = aws_iam_role.external_secrets_irsa.arn
    }]

    depends_on = [aws_eks_node_group.main]
}

resource "aws_iam_role" "external_secrets_irsa" {
    name = "${var.name_prefix}-irsa-external-secrets"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { Federated = aws_iam_openid_connect_provider.eks.arn }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })
}

# ClusterSecretStore — configured after ESO is installed
resource "kubectl_manifest" "cluster_secret_store" {
    yaml_body = <<-YAML
        apiVersion: external-secrets.io/v1beta1
        kind: ClusterSecretStore
        metadata:
        name: aws-secrets-manager
        spec:
        provider:
            aws:
            service: SecretsManager
            region: ${var.aws_region}
            auth:
                jwt:
                serviceAccountRef:
                    name: external-secrets
                    namespace: external-secrets
    YAML

    depends_on = [helm_release.external_secrets]
}