resource "aws_eks_node_group" "eks_cluster_worker_node" {
    cluster_name = aws_eks_cluster.my_eks_Cluster.name
    subnet_ids = local.eks_cluster_master_subnet_ids
    node_role_arn = aws_iam_role.eks_cluster_worker_node_role.arn
    node_group_name = "eks-cluster-private-worker-node-group"

    instance_types = ["t3.medium"]
    ami_type = "AL2023_x86_64_STANDARD"

    scaling_config {
        min_size = 1
        max_size = 2
        desired_size = 2
    }

    update_config {
        max_unavailable_percentage = 50
    }

    tags = {
        Name = "Private-Worker-Node-Group"
    }

    depends_on = [
        aws_iam_role_policy_attachment.aws_AmazonEC2ContainerRegistryReadOnly_attachment,
        aws_iam_role_policy_attachment.aws_AmazonEKS_CNI_Policy_attachment,
        aws_iam_role_policy_attachment.aws_AmazonEKSWorkerNodePolicy_attachment
    ]
}