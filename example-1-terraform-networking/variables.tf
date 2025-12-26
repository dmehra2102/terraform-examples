variable "aws_region" {
    type = string
    default = "ap-south-1"
    description = "The AWS region where resources will get created."
}

variable "vpc_name" {
    type = string
    description = "The name for the VPC."
}

variable "cidr_block" {
    type = string
    description = "The CIDR block for the VPC."
}

variable "public_subnets_cidr" {
    type = list(string)
    description = "The list of public subnets."
}

variable "private_subnets_cidr" {
    type = list(string)
    description = "The list of private subnets."
}

variable "igw_name" {
    type = string
    description = "The name of internet gateway for the VPC."
}

variable "public_route_table_name" {
    type = string
    description = "The Name for the public route table"
}

variable "private_route_table_name" {
    type = string
    description = "The Name for the private route table"
}

variable "nat_gateway_name" {
    type = string
    description = "The name of the NAT Gateway."
}