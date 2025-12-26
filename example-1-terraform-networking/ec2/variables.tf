variable "instance_ami" {
    type = string
    description = "The AMI (Amazon Machine Image) ID to use for the instance"
}

variable "instance_type" {
    type = string
    description = "Instance type to use for the instance."
}

variable "subnet_id" {
    type = string
    description = "VPC Subnet ID to launch in."
}

variable "access_key_name" {
    type = string
    description = "Key name of the Key Pair to use for the instance."
}

variable "security_groups" {
    type = list(string)
    description = "The list of security group for instance."
}