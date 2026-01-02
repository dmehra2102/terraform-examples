# EKS Cluster Control Plane Role
resource "aws_iam_role" "eks_cluster_role" {
    name = "${local.cluster_name}-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Satement = [
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
        Satement = [
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