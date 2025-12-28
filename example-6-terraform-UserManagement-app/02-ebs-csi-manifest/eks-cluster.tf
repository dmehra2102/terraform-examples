resource "aws_eks_cluster" "my_eks_cluster" {
    name = var.eks_cluster_name
    version = var.eks_version
    role_arn = aws_iam_role.eks_cluster_control_plane_role.arn

    vpc_config {
        subnet_ids = local.eks_cluster_subnet_ids
    }

    kubernetes_network_config {
        service_ipv4_cidr = "172.0.0.0/16"
    }

    enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy_policy_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController_policy_attachment
    ]
}