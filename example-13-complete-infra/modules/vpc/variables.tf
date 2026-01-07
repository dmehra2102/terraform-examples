variable "name_prefix" {
    type        = string
    description = "Prefix for naming VPC resources."
}

variable "region" {
    type        = string
    description = "AWS region."
}

variable "vpc_cidr" {
    type        = string
    description = "CIDR block for the VPC."
}

variable "az_count" {
    type        = number
    description = "Number of AZs to use."
    default     = 2
}

variable "enable_interface_endpoints" {
    type        = bool
    description = "Enable interface endpoints for ECR to reduce NAT costs."
    default     = true
}

variable "tags" {
    type        = map(string)
    description = "Common tags."
    default     = {}
}
