resource "aws_eks_node_group" "private_worker_node_group" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_role_arn = aws_iam_role.eks_cluster_worker_node_role.arn
    subnet_ids = var.worker_node_subnet_ids

    ami_type = var.worker_node_ami_type
    capacity_type = "ON_DEMAND"
    instance_types = var.worker_node_instance_types

    scaling_config {
        desired_size = 1
        min_size = 1
        max_size = 2
    }

    update_config {
        max_unavailable = 1    
        #max_unavailable_percentage = 50    # ANY ONE TO USE
    }

    tags = {
        Name = "private-worker-node-group"
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_AmazonEKS_CNI_policy_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEBSCSIDriverPolicy_policy_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEKSWorkerNodePolicy_policy_attachment,
        aws_iam_role_policy_attachment.eks_AmazonEC2ContainerRegistryReadOnly_policy_attachment,
    ]
}