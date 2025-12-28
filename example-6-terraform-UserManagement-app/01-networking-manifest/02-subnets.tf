resource "aws_subnet" "my_vpc_public_subnets" {
    vpc_id = aws_vpc.my_vpc.id
    count = length(var.vpc_public_subnets_cidr_block)
    cidr_block = var.vpc_public_subnets_cidr_block[count.index]
    availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "my-vpc-public-subnet-${count.index}"
    }
}

resource "aws_subnet" "my_vpc_private_subnets" {
    vpc_id = aws_vpc.my_vpc.id
    count = length(var.vpc_private_subnets_cidr_block)
    cidr_block = var.vpc_private_subnets_cidr_block[count.index]
    availability_zone = data.aws_availability_zones.availability_zones.names[count.index]

    tags = {
        Name = "my-vpc-private-subnet-${count.index}"
    }
}