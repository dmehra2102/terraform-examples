variable "name_prefix" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "az_count" {
    type    = number
    default = 3
}

variable "common_tags" {
    type = map(string)
}

variable "public_subnets_cidr" {
    type = list(string)
    description = "The list of CIDR block for Public subnets"
}

variable "private_subnets_cidr" {
    type = list(string)
    description = "The list of CIDR block for Private subnets"
}