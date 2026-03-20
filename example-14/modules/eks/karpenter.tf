# =================================================================
# Karpenter autoscaler — NodePool + EC2NodeClass CRDs + IRSA
# =================================================================
resource "aws_iam_role" "karpenter_controller" {
    count = var.enable_karpenter ? 1 : 0
    name  = "${var.name_prefix}-irsa-karpenter-controller"

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
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })
}

resource "aws_iam_policy" "karpenter_controller" {
    count = var.enable_karpenter ? 1 : 0
    name        = "${var.name_prefix}-karpenter-controller"
    description = "Karpenter controller permissions to manage EC2 nodes"

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid    = "AllowScopedEC2InstanceActions"
            Effect = "Allow"
            Action = [
            "ec2:RunInstances",
            "ec2:CreateFleet",
            "ec2:CreateLaunchTemplate",
            "ec2:DeleteLaunchTemplate",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeImages",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceTypeOfferings",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSpotPriceHistory",
            "ec2:DescribeSubnets",
            "ec2:TerminateInstances",
            ]
            Resource = "*"
            Condition = {
            StringEquals = {
                "aws:RequestedRegion" = var.aws_region
            }
            }
        },
        {
            Sid    = "AllowPassNodeRole"
            Effect = "Allow"
            Action = "iam:PassRole"
            Resource = aws_iam_role.node_group.arn
        },
        {
            Sid    = "AllowInterruptionHandling"
            Effect = "Allow"
            Action = [
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ReceiveMessage",
            ]
            Resource = aws_sqs_queue.karpenter_interruption[0].arn
        },
        {
            Sid    = "AllowSSMGetParameter"
            Effect = "Allow"
            Action = "ssm:GetParameter"
            Resource = "arn:aws:ssm:*:*:parameter/aws/service/eks/optimized-ami/*"
        },
        {
            Sid    = "AllowPricingForSpot"
            Effect = "Allow"
            Action = "pricing:GetProducts"
            Resource = "*"
        },
        {
            Sid    = "EKSClusterEndpointLookup"
            Effect = "Allow"
            Action = "eks:DescribeCluster"
            Resource = aws_eks_cluster.main.arn
        }
    ]
    })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
    count      = var.enable_karpenter ? 1 : 0
    role       = aws_iam_role.karpenter_controller[0].name
    policy_arn = aws_iam_policy.karpenter_controller[0].arn
}

# SQS Queue for EC2 interruption notifications (Spot)
resource "aws_sqs_queue" "karpenter_interruption" {
    count = var.enable_karpenter ? 1 : 0
    name                      = "${var.name_prefix}-karpenter-interruption"
    message_retention_seconds = 300
    sqs_managed_sse_enabled = true

    tags = {
        Name = "${var.name_prefix}-karpenter-interruption"
    }
}

# “Allow EventBridge and SQS service to send messages to this Karpenter interruption queue.”
resource "aws_sqs_queue_policy" "karpenter_interruption" {
    count = var.enable_karpenter ? 1 : 0
    queue_url = aws_sqs_queue.karpenter_interruption[0].id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = ["events.amazonaws.com", "sqs.amazonaws.com"]
            }
            Action = "sqs:SendMessage"
            Resource = aws_sqs_queue.karpenter_interruption[0].arn
        }]
    })
}

# EventBridge rules send to --> SQS for interruption events
resource "aws_cloudwatch_event_rule" "karpenter_spot_interruption" {
    count = var.enable_karpenter ? 1 : 0
    name        = "${var.name_prefix}-karpenter-spot-interruption"
    description = "Spot Instance Interruption Warning → Karpenter"

    event_pattern = jsonencode({
        source = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
    })
}

resource "aws_cloudwatch_event_target" "karpenter_spot_interruption" {
    count = var.enable_karpenter ? 1 : 0
    rule = aws_cloudwatch_event_rule.karpenter_spot_interruption[0].name
    target_id = "KarpenterInterruptionQueue"
    arn = aws_sqs_queue.karpenter_interruption[0].arn
}

# Karpenter Helm Chart
resource "kubernetes_namespace" "karpenter" {
    count = var.enable_karpenter ? 1 : 0

    metadata {
        name = "karpenter"
        labels = { "app.kubernetes.io/managed-by" = "Terraform" }
    }
    depends_on = [aws_eks_addon.coredns]
}

resource "helm_release" "karpenter" {
    count = var.enable_karpenter ? 1 : 0
    name = "karpenter"
    repository = "oci://public.ecr.aws/karpenter"
    chart      = "karpenter"
    version    = var.karpenter_version
    namespace  = kubernetes_namespace.karpenter[0].metadata[0].name
    atomic     = true
    timeout    = 300

    set = [ {
        name = "settings.clusterName"
        value = aws_eks_cluster.main.name
    }, {
        name = "settings.interruptionQueue"
        value = aws_sqs_queue.karpenter_interruption[0].name
    }, {
        name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = aws_iam_role.karpenter_controller[0].arn
    }, {
        name  = "controller.resources.requests.cpu"
        value = "250m"
    }, {
        name  = "controller.resources.requests.memory"
        value = "512Mi"
    }, {
        name  = "controller.resources.limits.memory"
        value = "1Gi"
    } ]

    depends_on = [ aws_eks_node_group.main ]
}

# NodePool --> When and why should nodes be created
resource "kubectl_manifest" "karpenter_node_pool" {
    count = var.enable_karpenter ? 1 : 0

    yaml_body = <<-YAML
        apiVersion: karpenter.sh/v1beta1
        kind: NodePool
        metadata:
            name: default
        spec:
            template:
                spec:
                    nodeClassRef:
                        apiVersion: karpenter.k8s.aws/v1beta1
                        kind: EC2NodeClass
                        name: default
                    requirements:
                        -   key: karpenter.sh/capacity-type
                            operator: In
                            values: ["spot", "on-demand"]
                        -   key: kubernetes.io/arch
                            operator: In
                            values: ["amd64"]
                        -   key: karpenter.k8s.aws/instance-category
                            operator: In
                            values: ["c", "m", "r"]
                        -   key: karpenter.k8s.aws/instance-generation
                            operator: Gt
                            values: ["5"]
            limits:
                cpu: 1000
                memory: 4000Gi
            disruption:
                consolidationPolicy: WhenUnderutilized
                consolidateAfter: 30s
    YAML

    depends_on = [helm_release.karpenter]
}

# EC2NodeClass --> How should the node be created?
resource "kubectl_manifest" "karpenter_node_class" {
    count = var.enable_karpenter ? 1 : 0

    yaml_body = <<-YAML
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        metadata:
        name: default
        spec:
            amiFamily: AL2
            role: "${aws_iam_role.node_group.name}"
            subnetSelectorTerms:
                - tags:
                    karpenter.sh/discovery: "${aws_eks_cluster.main.name}"
            securityGroupSelectorTerms:
                - tags:
                    karpenter.sh/discovery: "${aws_eks_cluster.main.name}"
            blockDeviceMappings:
                - deviceName: /dev/xvda
                ebs:
                    volumeSize: 100Gi
                    volumeType: gp3
                    iops: 3000
                    throughput: 125
                    encrypted: true
            metadataOptions:
                httpTokens: required        # IMDSv2 enforced
                httpPutResponseHopLimit: 2
    YAML

    depends_on = [helm_release.karpenter]
}
