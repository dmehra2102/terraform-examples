resource "aws_iam_role" "eks_cluster_control_plane_role" {
    name = "eks-cluster-control-plane-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = "AllowEksRole"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy_policy_attachment" {
    role = aws_iam_role.eks_cluster_control_plane_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController_policy_attachment" {
    role = aws_iam_role.eks_cluster_control_plane_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}