variable "cluster_name" {
    type        = string
    description = "EKS cluster name"
}

variable "vpc_cidr" {
    type        = string
    description = "VPC CIDR block"
}

variable "availability_zones" {
    type        = list(string)
    description = "Availability zones"
}

variable "public_subnet_cidrs" {
    type        = list(string)
    description = "Public subnet CIDR blocks"
}

variable "private_subnet_cidrs" {
    type        = list(string)
    description = "Private subnet CIDR blocks"
}

variable "tags" {
    type        = map(string)
    description = "Tags to apply to resources"
}
