resource "aws_eks_cluster" "my_eks_Cluster" {
    name = "my-eks-cluster"
    version = "1.34"
    role_arn = aws_iam_role.eks_cluster_master_node_role.arn

    vpc_config {
        endpoint_public_access  = true
        subnet_ids = local.eks_cluster_master_subnet_ids
    }

    kubernetes_network_config {
        service_ipv4_cidr = "172.20.0.0/16"
    }

    enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy_attachment
    ]
}