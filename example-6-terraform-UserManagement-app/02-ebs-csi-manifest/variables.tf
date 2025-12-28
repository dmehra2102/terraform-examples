variable "eks_cluster_name" {
    type = string
    description = "The name of the EKS cluster"
}

variable "eks_version" {
    type = string
    description = "The name of the EKS version"
}

variable "worker_node_ami_type" {
    type = string
    description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group."
}

variable "worker_node_instance_types" {
    type = list(string)
    description = "List of instance types associated with the EKS Node Group."
}
