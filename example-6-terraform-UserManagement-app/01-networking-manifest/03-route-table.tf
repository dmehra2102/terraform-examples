# Create Internet Gateway
resource "aws_internet_gateway" "my_vpc_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = var.igw_name
    }
}

resource "aws_route_table" "my_vpc_public_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = var.public_route_table_name
    }
}

resource "aws_route_table_association" "my_vpc_public_route_table_association" {
    count = length(local.public_subnet_ids)
    subnet_id = local.public_subnet_ids[count.index]
    route_table_id = aws_route_table.my_vpc_public_route_table.id
}

# Create Elastic IP for NAT gateway
resource "aws_eip" "nat_elastic_ip" {
    domain = "vpc"

    tags = {
        Name = "nat-eip"
    }
}

# Create NAT gateway with elastic IP
resource "aws_nat_gateway" "my_vpc_nat_gateway" {
    subnet_id = local.public_subnet_ids[0]
    allocation_id = aws_eip.nat_elastic_ip.id

    tags = {
        Name = var.nat_gateway_name
    }
}

resource "aws_route_table" "my_vpc_private_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_vpc_nat_gateway.id
    }

    tags = {
        Name = var.private_route_table_name
    }
}

resource "aws_route_table_association" "my_vpc_private_route_table_association" {
    count = length(local.private_subnet_ids)
    subnet_id = local.private_subnet_ids[count.index]
    route_table_id = aws_route_table.my_vpc_private_route_table.id
}