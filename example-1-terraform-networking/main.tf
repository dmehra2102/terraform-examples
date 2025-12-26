module "vpc" {
    source = "./vpc"
    vpc_name = var.vpc_name
    cidr_block = var.cidr_block
    availability_zones = data.aws_availability_zones.availability_zones.names
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
}