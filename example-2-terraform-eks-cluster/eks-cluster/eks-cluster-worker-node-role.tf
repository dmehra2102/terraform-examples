resource "aws_iam_role" "eks_cluster_worker_node_role" {
    name = "eks-cluster-worker-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid  = "EC2AllowRole"
                Action   = "sts:AssumeRole"
                Effect   = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSWorkerNodePolicy_policy_attachment" {
    role = aws_iam_role.eks_cluster_worker_node_role.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_policy_attachment" {
    role = aws_iam_role.eks_cluster_worker_node_role.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly_policy_attachment" {
    role = aws_iam_role.eks_cluster_worker_node_role.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
