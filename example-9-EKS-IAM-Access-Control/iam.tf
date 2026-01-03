# EKS Cluster Control Plane Role
resource "aws_iam_role" "eks_cluster_role" {
    name = "${local.cluster_name}-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid     = "EksClusterRole"
                Action  = "sts:AssumeRole"
                Effect  = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })

    tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role = aws_iam_role.eks_cluster_role.name
}

# EKS Node Worker Role
resource "aws_iam_role" "eks_node_role" {
    name = "${local.cluster_name}-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid     = "EksClusterRole"
                Action  = "sts:AssumeRole"
                Effect  = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    role = aws_iam_role.eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    role = aws_iam_role.eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
    role = aws_iam_role.eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Admin Group - Full Cluster Access
resource "aws_iam_group" "admin_group" {
    name = "${local.cluster_name}-admins"
}

resource "aws_iam_group_policy" "admin_group" {
    name = "${local.cluster_name}-admin-policy"
    group = aws_iam_group.admin_group.name

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid = "AssumeAdminRole"
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Resource = [
                aws_iam_role.eks_admin_role.arn
            ]
        }]
    })
}

# Developer Group - Dev/Staging namespace access
resource "aws_iam_group" "developer_group" {
    name = "${local.cluster_name}-developers"
}

resource "aws_iam_group_policy" "developer_group" {
    name = "${local.cluster_name}-developer-policy"
    group = aws_iam_group.admin_group.name

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid = "AssumeDeveloperRole"
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Resource = [
                aws_iam_role.eks_developer_role.arn // Todo: Needs to Create This Role
            ]
        }]
    })
}

# Readers Group - Read-only cluster access
resource "aws_iam_group" "eks_readers" {
    name = "${local.cluster_name}-readers"
}

resource "aws_iam_group_policy" "eks_readers_policy" {
    name   = "${local.cluster_name}-readers-policy"
    group  = aws_iam_group.eks_readers.name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "AssumeReaderRole"
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Resource = [
                    aws_iam_role.eks_reader_role.arn
                ]
            }
        ]
    })
}

# DevOps Group - Cluster operations and management
resource "aws_iam_group" "eks_devops" {
    name = "${local.cluster_name}-devops"
}

resource "aws_iam_group_policy" "eks_devops_policy" {
    name   = "${local.cluster_name}-devops-policy"
    group  = aws_iam_group.eks_devops.name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "AssumeDevOpsRole"
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Resource = [
                    aws_iam_role.eks_devops_role.arn
                ]
            }
        ]
    })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_admin_role" {
    name_prefix = "${local.cluster_name}eks-admin-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = "AllowAdminGroupAssumeRole"
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                }
                Condition = {
                    StringEquals = {
                        "sts:ExternalId" = "${local.cluster_name}-admin"
                    }
                }
            }
        ]
    })

    tags = local.common_tags
}

resource "aws_iam_role" "eks_developer_role" {
    name_prefix = "${local.cluster_name}eks-developer-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = "AllowDeveloperGroupAssumeRole"
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                }
            }
        ]
    })

    tags = local.common_tags
}

resource "aws_iam_role" "eks_reader_role" {
    name_prefix = "${local.cluster_name}-reader"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid    = "AllowReaderGroupAssumeRole"
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
        }
        ]
    })

    tags = local.common_tags
}

resource "aws_iam_role" "eks_devops_role" {
    name_prefix = "${local.cluster_name}-eks-devops-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid    = "AllowDevOpsGroupAssumeRole"
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
        }
        ]
    })

    tags = local.common_tags
}

# DevOps role policy for cluster operations
resource "aws_iam_role_policy" "eks_devops_eks_permissions" {
    name   = "${local.cluster_name}-devops-eks-permissions"
    role   = aws_iam_role.eks_devops_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid    = "EKSDescribeCluster"
            Effect = "Allow"
            Action = [
            "eks:DescribeCluster",
            "eks:ListClusters"
            ]
            Resource = "*"
        },
        {
            Sid    = "ECRAccess"
            Effect = "Allow"
            Action = [
            "ecr:GetAuthorizationToken",
            "ecr:DescribeRepositories"
            ]
            Resource = "*"
        }
        ]
    })
}