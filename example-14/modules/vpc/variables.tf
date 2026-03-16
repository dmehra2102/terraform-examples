variable "name_prefix" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "availability_zones" {
    type = list(string)
}

variable "public_subnet_cidrs" {
    type = list(string)
}

variable "private_subnet_cidrs" {
    type = list(string)
}

variable "database_subnet_cidrs" {
    type = list(string)
}

variable "cluster_name" {
    type = string
}

variable "single_nat_gateway" {
    type = bool
    default = false
}

variable "enable_flow_logs" {
    type = bool
    default = true
}

variable "log_retention_days" {
    type = number
    default = 90
}