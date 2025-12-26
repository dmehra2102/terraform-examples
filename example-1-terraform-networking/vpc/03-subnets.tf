resource "aws_subnet" "my_vpc_public_subnets" {
    vpc_id = aws_vpc.my-vpc.id
    count = length(var.public_subnets)

    map_public_ip_on_launch = true
    cidr_block = var.public_subnets[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "my-vpc-public-subnet-${count.index}"
    }
}

resource "aws_subnet" "my_vpc_private_subnets" {
    vpc_id = aws_vpc.my-vpc.id
    count = length(var.private_subnets)

    map_public_ip_on_launch = false
    cidr_block =  var.private_subnets[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "my-vpc-private-subnet-${count.index}"
    }
}