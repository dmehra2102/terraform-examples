resource "aws_eks_node_group" "eks_cluster_private_worker_node_group" {
    cluster_name = aws_eks_cluster.my_eks_cluster.name
    node_role_arn = aws_iam_role.eks_cluster_worker_node_role.arn
    subnet_ids = local.eks_cluster_worker_node_subnet_ids

    scaling_config {
        max_size = 3
        min_size = 1
        desired_size = 2
    }

    update_config {
        max_unavailable_percentage = 50
    }

    capacity_type = "ON_DEMAND"
    ami_type = var.worker_node_ami_type
    instance_types = var.worker_node_instance_types

    tags = {
        Name = "private-worker-node-group"
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_AmazonEKSWorkerNodePolicy_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEC2ContainerRegistryReadOnly_policy_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEKS_CNI_Policy_attachment, 
    ]
}