variable "eks_cluster_name" {
    type = string
    description = "The name of the EKS Cluster."
}

variable "eks_version" {
    type = string
    description = "Desired Kubernetes master version."
}

variable "control_plane_subnet_ids" {
    type = list(string)
    description = "List of subnet IDs. Must be in at least two different availability zones."
}

variable "worker_node_subnet_ids" {
    type = list(string)
    description = "Identifiers of EC2 Subnets to associate with the EKS Node Group."
}

variable "worker_node_ami_type" {
    type = string
    description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group."
}

variable "worker_node_instance_types" {
    type = list(string)
    description = "List of instance types associated with the EKS Node Group."
}