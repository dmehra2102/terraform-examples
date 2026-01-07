variable "name_prefix" {
    type        = string
    description = "Prefix for naming EKS resources."
}

variable "cluster_name" {
    type        = string
    description = "EKS cluster name."
}

variable "cluster_version" {
    type        = string
    description = "EKS Kubernetes version (e.g., 1.29, 1.34)."
}

variable "private_subnet_ids" {
    type        = list(string)
    description = "Private subnet IDs for EKS."
}

variable "kms_key_arn" {
    type        = string
    description = "KMS key ARN for secrets encryption."
}

variable "endpoint_private_access" {
    type        = bool
    description = "Enable private endpoint access."
    default     = true
}

variable "endpoint_public_access" {
    type        = bool
    description = "Enable public endpoint access."
    default     = false
}

variable "public_access_cidrs" {
    type        = list(string)
    description = "CIDRs allowed to access public endpoint (if enabled)."
    default     = ["0.0.0.0/0"]
}

variable "service_ipv4_cidr" {
    type        = string
    description = "Service CIDR for Kubernetes."
    default     = "172.20.0.0/16"
}

variable "enabled_cluster_log_types" {
    type        = list(string)
    description = "Control plane logs to enable."
    default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
    type        = number
    description = "CloudWatch log retention days."
    default     = 30
}

variable "node_desired_size" {
    type        = number
    default     = 1
}

variable "node_min_size" {
    type        = number
    default     = 1
}

variable "node_max_size" {
    type        = number
    default     = 3
}

variable "node_instance_types" {
    type        = list(string)
    default     = ["t3.medium"]
}

variable "node_capacity_type" {
    type        = string
    description = "ON_DEMAND or SPOT"
    default     = "ON_DEMAND"
}

variable "node_ami_type" {
    type        = string
    description = "AL2_x86_64 or BOTTLEROCKET_x86_64 etc."
    default     = "AL2023_x86_64_STANDARD"
}

variable "node_disk_size" {
    type        = number
    default     = 20
}

variable "node_labels" {
    type        = map(string)
    default     = {
        "workload" = "general"
    }
}

variable "tags" {
    type        = map(string)
    description = "Common tags."
    default     = {}
}
