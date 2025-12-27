resource "aws_eks_cluster" "eks_cluster" {
    name = var.eks_cluster_name
    role_arn = aws_iam_role.eks_cluster_control_plane_role.arn
    version = var.eks_version

    kubernetes_network_config {
        service_ipv4_cidr = "172.20.0.0/16"
    }

    vpc_config {
        subnet_ids = var.control_plane_subnet_ids
    }

    enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy_policy_attachement,
        aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController_policy_attachement
    ]
}