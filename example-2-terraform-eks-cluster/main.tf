module "vpc" {
    source = "./vpc"
    vpc_name = var.vpc_name
    cidr_block = var.cidr_block
    public_subnets_cidr = var.public_subnets_cidr
    private_subnets_cidr = var.private_subnets_cidr
    availability_zones = data.aws_availability_zones.availability_zones.names
    igw_name = var.igw_name
    public_route_table_name = var.public_route_table_name
    private_route_table_name = var.private_route_table_name
    nat_gateway_name = var.nat_gateway_name
}