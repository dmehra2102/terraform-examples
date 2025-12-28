variable "vpc_name" {
    type = string
    description = "The name of the vpc."
}

variable "vpc_cidr_block" {
    type = string
    description = "The CIDR block for the vpc."
}

variable "vpc_public_subnets_cidr_block" {
    type = list(string)
    description = "The list of CIDR block for public subnets."
}

variable "vpc_private_subnets_cidr_block" {
    type = list(string)
    description = "The list of CIDR block for private subnets."
}

variable "igw_name" {
    type = string
    description = "The name of the VPC internet gateway"
}

variable "nat_gateway_name" {
    type = string
    description = "The name of the VPC NAT gateway"
}

variable "public_route_table_name" {
    type = string
    description = "The name of the public route table"
}

variable "private_route_table_name" {
    type = string
    description = "The name of the private route table"
}