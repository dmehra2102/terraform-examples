module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "21.15.1"

    name = var.cluster_name
    kubernetes_version = var.cluster_version

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    enable_irsa = true

    endpoint_public_access = true
    endpoint_private_access = true

    # Cluster logging
    enabled_log_types = [
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
    ]

    addons = {
        coredns = {
            most_recent = true
            configuration_values = jsonencide({
                computeType = "Fargate"
                resources = {
                    limits = {
                        cpu = "0.25"
                        memory = "256Mi"
                    }
                    request = {
                        cpu = "0.25"
                        memory = "256Mi"
                    }
                }
            })
        }

        kube-proxy = {
            most_recent = true
            before_compute           = true
            service_account_role_arn = module.vpc_cni_irsa.arn
            configuration_values = jsonencode({
                env = {
                    ENABLE_PREFIX_DELEGATION = "true"
                    ENABLE_POD_ENI           = "true"
                    POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
                }
                enableNetworkPolicy = "true"
            })
        }

        vpc-cni = {
            most_recent = true
        }

        aws-ebs-csi-driver = {
            most_recent = true
            service_account_role_arn = module.ebs_csi_irsa.arn
        }
    }

    eks_managed_node_groups = {
        kafka_controllers = {
            name = "pool-controllers"

            instance_types = [var.controller_instance_type]
            capacity_type = "ON_DEMAND"

            min_size = var.controller_desired_size
            max_size = var.controller_desired_size
            desired_size = var.controller_desired_size

            use_custom_launch_template = true

            block_device_mappings = {
                xvda = {
                    device_name = "/dev/xvda"
                    ebs = {
                        volume_size = var.ebs_volume_size
                        volume_type = var.ebs_volume_type
                        iops        = var.ebs_iops
                        throughput  = var.ebs_throughput
                        encrypted   = true
                        # KMS key can be specified here for encryption
                        # kms_key_id  = aws_kms_key.ebs.arn
                        delete_on_termination = true
                    }
                }
            }

            subnet_ids = module.vpc.private_subnets

            # Taints to ensure only controller pods are scheduled here
            taints = [
                {
                    key    = "dedicated"
                    value  = "controller"
                    effect = "NoSchedule"
                }
            ]

            labels = {
                role        = "kafka-controller"
                workload    = "kafka"
                node-type   = "controller"
            }

            tags = merge(
                {
                    Name = "${var.cluster_name}-controller-node"
                    "k8s.io/cluster-autoscaler/enabled" = var.enable_cluster_autoscaler ? "true" : "false"
                    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
                },
                var.tags
            )

        }

        # Broker Node Group - dedicated for Kafka brokers
        kafka_brokers = {
            name = "pool-brokers"

            instance_types = [var.broker_instance_type]
            capacity_type  = "ON_DEMAND"

            min_size     = var.broker_desired_size
            max_size     = var.broker_desired_size + 3
            desired_size = var.broker_desired_size

            use_custom_launch_template = true

            block_device_mappings = {
                xvda = {
                    device_name = "/dev/xvda"
                    ebs = {
                        volume_size = var.ebs_volume_size
                        volume_type = var.ebs_volume_type
                        iops        = var.ebs_iops
                        throughput  = var.ebs_throughput
                        encrypted   = true
                        delete_on_termination = true
                    }
                }
            }

            subnet_ids = module.vpc.private_subnets

            taints = [
                {
                    key    = "dedicated"
                    value  = "kafka"
                    effect = "NoSchedule"
                }
            ]

            labels = {
                role        = "kafka-broker"
                workload    = "kafka"
                node-type   = "broker"
            }

            tags = merge(
                {
                    Name = "${var.cluster_name}-broker-node"
                    "k8s.io/cluster-autoscaler/enabled" = var.enable_cluster_autoscaler ? "true" : "false"
                    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
                },
                var.tags
            )
        }
    }

    enable_cluster_creator_admin_permissions = true
    tags = var.tags
}

# IRSA for VPC CNI
module "iam_iam-role-for-service-accounts" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
    version = "6.4.0"

    name = "VPC-CNI-IRSA-"
    use_name_prefix = true
    attach_vpc_cni_policy = true
    vpc_cni_enable_ipv4 = true

    oidc_providers = {
        main = {
            provider_arn = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:aws-node"]
        }
    }
}

# IRSA for EBS CSI Driver
module "ebs_csi_irsa" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
    version = "6.4.0"

    name      = "EBS-CSI-IRSA-"
    use_name_prefix = true
    attach_ebs_csi_policy = true

    oidc_providers = {
        main = {
            provider_arn               = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
        }
    }

    tags = var.tags
}

# IRSA for AWS Load Balancer Controller
module "aws_lb_controller_irsa" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
    version = "6.4.0"

    name            = "AWS-LB-Controller-IRSA-"
    use_name_prefix = true
    attach_load_balancer_controller_policy = true

    oidc_providers = {
        main = {
            provider_arn               = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
        }
    }

    tags = var.tags
}

# Security group rule to allow Kafka inter-broker communication
resource "aws_security_group_rule" "kafka_inter_broker" {
    description              = "Allow Kafka inter-broker communication"
    type                     = "ingress"
    from_port                = 9091
    to_port                  = 9097
    protocol                 = "tcp"
    security_group_id        = module.eks.node_security_group_id
    source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "kafka_controller" {
    description              = "Allow Kafka controller communication"
    type                     = "ingress"
    from_port                = 9093
    to_port                  = 9093
    protocol                 = "tcp"
    security_group_id        = module.eks.node_security_group_id
    source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "kafka_metrics" {
    description              = "Allow Prometheus metrics scraping"
    type                     = "ingress"
    from_port                = 9404
    to_port                  = 9404
    protocol                 = "tcp"
    security_group_id        = module.eks.node_security_group_id
    source_security_group_id = module.eks.node_security_group_id
}
