locals {
    azs = slice(data.aws_availability_zones.available.names,0,var.az_count)
}

data "aws_availability_zones" "available" {
    region = var.region
    filter {
        name   = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}

# AWS VPC
resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.tags, {
        Name = "${var.name_prefix}-vpc"
    })
}

# Public Subnets
resource "aws_subnet" "public" {
    for_each = {for idx, az in local.azs : idx => az}

    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, each.key)
    availability_zone = each.value
    map_public_ip_on_launch = true

    tags = merge(var.tags,{
        Name = "${var.name_prefix}-public-${each.value}"
        "kubernetes.io/role/elb" = "1"
    })
}

# Private Subnets
resource "aws_subnet" "private" {
    for_each = {for idx,key in local.azs: idx => key}

    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, each.key+100)
    availability_zone = each.value
    map_public_ip_on_launch = false

    tags = merge(var.tags,{
        Name = "${var.name_prefix}-private-${each.value}"
        "kubernetes.io/role/internal-elb" = "1"
    })
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    
    tags = merge(var.tags,{
        Name = "${var.name_prefix}-igw"
    })
}

# Single Nat Gateway for cost saving
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = merge(var.tags, {
        "Name" = "${var.name_prefix}-nat-eip"
    })
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id = values(aws_subnet.public)[0].id

    tags = merge(var.tags, {
        "Name" = "${var.name_prefix}-nat-gateway"
    })

    depends_on = [ aws_internet_gateway.this ]
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = merge(var.tags, {
        "Name" = "${var.name_prefix}-public-rt"
    })
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public

    subnet_id = each.value.id
    route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = merge(var.tags, {
        "Name" = "${var.name_prefix}-private-rt"
    })
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.private

    subnet_id = each.value.id
    route_table_id = aws_route_table.private.id
}

# VPC endpoints to reduce NAT gateway costs
resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.this.id
    service_name = "com.amazonas.${var.region}.s3"
    vpc_endpoint_type = "Gateway"

    route_table_ids = [ aws_route_table.private.id ]

    tags = merge(var.tags, {
        "Name" = "${var.name_prefix}-s3-endpoint"
    })
}

resource "aws_vpc_endpoint" "dynamodb" {
    vpc_id = aws_vpc.this.id
    service_name = "com.amazonas.${var.region}.dynamodb"
    vpc_endpoint_type = "Gateway"

    route_table_ids = [ aws_route_table.private.id ]

    tags = merge(var.tags, {
        "Name" = "${var.name_prefix}-dynamodb-endpoint"
    })
}

# Interface endpoints security
resource "aws_security_group" "endpoints" {
    name = "${var.name_prefix}-vpc-endpoints-sg"
    description = "Security group for interface VPC endpoints"
    vpc_id      = aws_vpc.this.id

    ingress {
        description = "Allow from private subnets"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ for s in aws_subnet.private : s.cidr_block ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, { 
        "Name" = "${var.name_prefix}-endpoints-sg" 
    })
}

resource "aws_vpc_endpoint" "ecr_api" {
    count              = var.enable_interface_endpoints ? 1 : 0
    vpc_id             = aws_vpc.this.id
    service_name       = "com.amazonaws.${var.region}.ecr.api"
    vpc_endpoint_type  = "Interface"
    subnet_ids         = [for s in aws_subnet.private : s.id]
    security_group_ids = [aws_security_group.endpoints.id]

    private_dns_enabled = true

    tags = merge(var.tags, { 
        "Name" = "${var.name_prefix}-ecr-api-endpoint" 
    })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    count = var.enable_interface_endpoints ? 1 : 0
    vpc_id = aws_vpc.this.id
    service_name       = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_endpoint_type  = "Interface"
    subnet_ids = [for s in aws_subnet.private : s.id]
    security_group_ids = [ aws_security_group.endpoints.id ]

    private_dns_enabled = true

    tags = merge(var.tags, { 
        "Name" = "${var.name_prefix}-ecr-dkr-endpoint" 
    })
}