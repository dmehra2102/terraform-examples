resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-vpc"
    })
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-igw"
    })
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    availability_zone = var.availability_zones[count.index]
    cidr_block = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = true

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-public-subnet-${count.index + 1}"
        Type = "Public"
        "kubernetes.io/role/elb" = "1"
    })
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    availability_zone = var.availability_zones[count.index]
    cidr_block = var.private_subnet_cidrs[count.index]
    map_public_ip_on_launch = false

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-private-subnet-${count.index + 1}"
        Type = "Private"
        "kubernetes.io/role/internal-elb" = "1"
    })
}

resource "aws_eip" "nat" {
    count = length(var.availability_zones)
    domain = "vpc"

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-eip-${count.index + 1}"
    })
}

# Creating NAT Gateway in Per AZ's for High Avialibility
resource "aws_nat_gateway" "main" {
    count = length(var.availability_zones)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    
    tags = merge(var.tags, {
        Name = "${var.cluster_name}-nat-${count.index + 1}"
    })

    depends_on = [ aws_internet_gateway.main ]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-public-rt"
    })
}

resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-private-rt"
    })
}

resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private)
    route_table_id = aws_route_table.private.id
    subnet_id = aws_subnet.private[count.index].id
}