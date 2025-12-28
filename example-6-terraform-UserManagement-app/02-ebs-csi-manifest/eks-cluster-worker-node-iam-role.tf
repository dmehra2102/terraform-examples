resource "aws_iam_role" "eks_cluster_worker_node_role" {
    name = "eks-cluster-worker-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = "AllowEC2Role"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSWorkerNodePolicy_attachment" {
    role = aws_iam_role.eks_cluster_worker_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy_attachment" {
    role = aws_iam_role.eks_cluster_worker_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly_policy_attachment" {
    role = aws_iam_role.eks_cluster_worker_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}