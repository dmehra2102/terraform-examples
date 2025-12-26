variable "cidr_block" {
    type = string
    description = "The CIDR block for the VPC."
}

variable "vpc_name" {
    type = string
    description = "The name for the VPC."
}

variable "common_tags" {
    type = object({})
    default = {
        Environment = "development"
        Team = "tech"
    }
}

variable "availability_zones" {
    type = list(string)
    description = "The AZ for the subnet."
}

variable "public_subnets" {
    type = list(string)
    description = "The list of public subnets."
}

variable "private_subnets" {
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