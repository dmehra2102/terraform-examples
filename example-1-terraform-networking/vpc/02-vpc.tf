resource "aws_vpc" "my-vpc" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.common_tags,{
        Name = var.vpc_name
    })
}