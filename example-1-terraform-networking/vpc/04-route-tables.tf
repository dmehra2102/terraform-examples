# Create Internet Gateway
resource "aws_internet_gateway" "my_vpc_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = var.igw_name
    }
}

# Create Public Route Table
resource "aws_route_table" "my_vpc_public_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        gateway_id = aws_internet_gateway.my_vpc_igw.id
        cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = var.public_route_table_name
    }
}

# Create Public Route Table Association wiht Public subnets
resource "aws_route_table_association" "my_vpc_public_route_table_association" {
    count = length(var.public_subnets)
    subnet_id = var.public_subnets[count.index]
    route_table_id = aws_route_table.my_vpc_public_route_table.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
    domain = "vpc"

    tags = {
        Name = "nat-eip"
    }
}

# Create NAT Gateway with Elastic IP
resource "aws_nat_gateway" "my_vpc_nat_gateway" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = var.public_subnets[0]

    tags = {
        Name = var.nat_gateway_name
    }

    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.my_vpc_igw]
}

# Create private route table
resource "aws_route_table" "my_vpc_private_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_vpc_nat_gateway.id
    }

    tags = {
        Name = var.private_route_table_name
    }
}

# Create private route table association
resource "aws_route_table_association" "my_vpc_private_route_table_association" {
    count = length(var.private_subnets)
    subnet_id = var.private_subnets[count.index]
    route_table_id = aws_route_table.my_vpc_private_route_table.id
}