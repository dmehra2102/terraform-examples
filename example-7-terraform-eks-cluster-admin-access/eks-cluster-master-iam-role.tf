resource "aws_iam_role" "eks_cluster_master_node_role" {
    name = "eks-cluster-master-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = "EksMasterRole"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy_attachment" {
    role = aws_iam_role.eks_cluster_master_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController_attachment" {
    role = aws_iam_role.eks_cluster_master_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}