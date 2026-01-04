variable "cluster_version" {
    type = string
    description = "Kubernetes Version"
}

variable "node_group_desired_size" {
    type = number
    description = "Desired number of nodes"
}

variable "node_group_min_size" {
    type        = number
    description = "Minimum number of nodes"
}

variable "node_group_max_size" {
    type        = number
    description = "Maximum number of nodes"
}

variable "node_instance_types" {
    type        = list(string)
    description = "EC2 instance types for nodes"
}

variable "enable_spot_instances" {
    type        = bool
    description = "Enable spot instances for cost savings"
}

variable "cluster_name" {
    type = string
    description = "The name of the cluster"
}

variable "tags" {
    type        = map(string)
    description = "Tags to apply to resources"
}

variable "private_subnet_ids" {
    type = list(string)
    description =  "Private subnet IDs"
}

variable "vpc_id" {
    type = string
    description = "The VPC ID"
}