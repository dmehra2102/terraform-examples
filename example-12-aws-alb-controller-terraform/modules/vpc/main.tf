data "aws_availability_zones" "available" {
    state = "available"
    filter {
        name = "opt-in-status"
        values = [ "opt-in-not-required" ]
    }
}

# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.common_tags,{
        Name = "${var.name_prefix}-vpc"
    })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(var.common_tags, {
        Name = "${var.name_prefix}-igw"
    })
}

# Public Subnet
resource "aws_subnet" "public" {
    count = var.az_count

    vpc_id = aws_vpc.main.id
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = var.public_subnets_cidr[count.index]
    map_public_ip_on_launch = true

    tags = merge(var.common_tags,{
        Name = "${var.name_prefix}-public-subnet-${count.index}"
        Type = "Public"
        "kubernetes.io/role/elb" = "1"
    })
}

# Private Subnet
resource "aws_subnet" "private" {
    count = var.az_count

    vpc_id = aws_vpc.main.id
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = var.private_subnets_cidr[count.index]
    map_public_ip_on_launch = false

    tags = merge(var.common_tags,{
        Name = "${var.name_prefix}-private-subnet-${count.index}"
        Type = "Private"
        "kubernetes.io/role/internal-elb" = "1"
    })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
    count = length(aws_subnet.private)

    domain = "vpc"

    tags = merge(var.common_tags, {
        Name = "${var.name_prefix}-nat-eip-${count.index}"
    })

    depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
    count = length(aws_subnet.public)

    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id

    tags = merge(var.common_tags, {
        Name = "${var.name_prefix}-nat-gw-${count.index}"
    })

    depends_on = [aws_internet_gateway.main]
}

# Pubic Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id =  aws_internet_gateway.main.id
    }

    tags = merge(var.common_tags,{
        Name = "${var.name_prefix}-public-rt"
    })
}

# Public Route Table Association With Public Subnets
resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)

    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id
}

# Private Route Table Per  Az's
resource "aws_route_table" "private" {
    count = length(aws_subnet.private)

    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = merge(var.common_tags,{
        Name = "${var.name_prefix}-private-rt-${count.index}"
    })
}

# Private Route Table Association With Private Subnets
resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private)

    route_table_id = aws_route_table.private[count.index].id
    subnet_id = aws_subnet.private[count.index].id
}

# VPC Endpoints (for connecting to AWS Services privately without going to the internet)
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${data.aws_region.current.region}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = aws_route_table.private[*].id

    tags = merge(var.common_tags, {
        Name = "${var.name_prefix}-s3-endpoint"
    })
}

resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
    vpc_endpoint_type = "Interface"
    subnet_ids = aws_subnet.private[*].id
    security_group_ids  = []
    private_dns_enabled = true

    tags = merge(var.common_tags, {
        Name = "${var.name_prefix}-ecr-api-endpoint"
    })
}