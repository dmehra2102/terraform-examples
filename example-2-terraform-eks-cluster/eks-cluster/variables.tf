variable "eks_cluster_name" {
    type = string
    description = "The name of the EKS Cluster."
}

variable "eks_version" {
    type = string
    description = "Desired Kubernetes master version."
}

variable "subnet_ids" {
    type = list(string)
    description = "List of subnet IDs. Must be in at least two different availability zones."
}