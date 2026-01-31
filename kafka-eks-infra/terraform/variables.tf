variable "aws_region" {
    description = "AWS region for all resources"
    type = string
    default = "ap-south-1"
}

variable "environment" {
    description = "Environment name (dev, staging, prod)"
    type = string
    default = "prod"
}

variable "cluster_name" {
    description = "EKS cluster name"
    type = string
    default = "kafka-eks-cluster"
}

variable "cluster_version" {
    description = "Kubernetes version for EKS cluster"
    type        = string
    default     = "1.34"
}

variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "availability_zones" {
    description = "List of availability zones - must be 3 for HA"
    type        = list(string)
    default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "controller_instance_type" {
    description = "EC2 instance type for Kafka controller nodes"
    type        = string
    default     = "c7g.large"
}

variable "broker_instance_type" {
    description = "EC2 instance type for Kafka broker nodes"
    type        = string
    default     = "r7g.xlarge"
}

variable "controller_desired_size" {
    description = "Desired number of controller nodes"
    type        = number
    default     = 3
}

variable "broker_desired_size" {
    description = "Desired number of broker nodes"
    type        = number
    default     = 3
}

variable "enable_cluster_autoscaler" {
    description = "Enable kubernetes cluster autoscaler"
    type = bool
    default = false
}

variable "ebs_volume_size" {
    description = "Root EBS volume size in GB for nodes"
    type = number
    default = 100
}

variable "ebs_volume_type" {
    description = "EBS volume type for node root volumes"
    type        = string
    default     = "gp3"
}

variable "ebs_iops" {
    description = "IOPS for gp3 volumes"
    type        = number
    default     = 3000
}

variable "ebs_throughput" {
    description = "Throughput in MiB/s for gp3 volumes"
    type        = number
    default     = 125
}

variable "strimzi_version" {
    description = "Strimzi Kafka operator Helm chart version"
    type        = string
    default     = "0.50.0"
}

variable "install_strimzi" {
    description = "Whether to install Strimzi operator via Helm"
    type        = bool
    default     = true
}

variable "install_aws_lb_controller" {
    description = "Whether to install AWS Load Balancer Controller"
    type        = bool
    default     = true
}

variable "install_metrics_server" {
    description = "Whether to install Kubernetes metrics server"
    type        = bool
    default     = true
}

variable "tags" {
    description = "Additional tags for all resources"
    type        = map(string)
    default     = {}
}