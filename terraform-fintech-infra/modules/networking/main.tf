data "aws_availability_zones" "available" {
    state = "available"
    filter {
        name = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}

locals {
    azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

    common_tags = merge(
        var.tags,
        {
            Module      = "networking"
            ManagedBy   = "terraform"
            CostCenter  = "infrastructure"
            Component   = "network"
        }
    )
}

# tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(local.common_tags, {
        Name = "${var.environment}-vpc"
    })
}

# Public Subnets (ALB, NAT Gateways)
resource "aws_subnet" "public" {
    count = var.az_count
    vpc_id = aws_vpc.main.id
    map_public_ip_on_launch = false # disabling it for security
    availability_zone = local.azs[count.index]
    cidr_block = cidrsubnet(var.vpc_cidr, 4, count.index)

    tags = merge(local.common_tags, {
        Name                                     = "${var.environment}-public-${local.azs[count.index]}"
        "kubernetes.io/role/elb"                    = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        Tier                                        = "public"
    })
}

# Private Subnets (EKS Node Groups)
resource "aws_subnet" "private" {
    count = var.az_count
    vpc_id = aws_vpc.main.id
    availability_zone = local.azs[count.index]
    cidr_block = cidrsubnet(var.vpc_cidr, 4, 10 + count.index)

    tags = merge(local.common_tags,{
        Name                                 = "${var.environment}-private-${local.azs[count.index]}"
        "kubernetes.io/role/internal-elb"    = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        Tier                                 = "private"
    })
}

# Private Data Subnets (MSK, RDS)
resource "aws_subnet" "private_data" {
    count = var.az_count
    vpc_id = aws_vpc.main.id
    availability_zone = local.azs[count.index]
    cidr_block = cidrsubnet(var.vpc_cidr, 4, 100 + count.index)

    tags = merge(local.common_tags,{
        Name      = "${var.environment}-private-data-${local.azs[count.index]}"
        Tier      = "private-data"
    })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(local.common_tags, {
        Name = "${var.environment}-igw"
    })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    count  = var.az_count
    domain = "vpc"

    tags = merge(local.common_tags,{
        Name = "${var.environment}-nat-eip-${local.azs[count.index]}"
    })

    depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
    count = var.az_count
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id

    tags = merge(local.common_tags,{
        Name = "${var.environment}-nat-${local.azs[count.index]}"
    })

    depends_on = [ aws_internet_gateway.main ]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = merge(local.common_tags,{
        Name = "${var.environment}-public-rt"
    })
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    count = var.az_count

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = merge(local.common_tags,{
        Name = "${var.environment}-private-rt-${local.azs[count.index]}"
    })
}

resource "aws_route_table" "private_data" {
    count  = var.az_count
    vpc_id = aws_vpc.main.id

    # No internet route - data tier is fully isolated

    tags = merge(local.common_tags,{
        Name = "${var.environment}-private-data-rt-${local.azs[count.index]}"
    })
}

resource "aws_route_table_association" "public" {
    count = var.az_count
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "private" {
    count = var.az_count
    route_table_id = aws_route_table.private.id
    subnet_id = aws_subnet.private[count.index].id
}

resource "aws_route_table_association" "private_data" {
    count = var.az_count
    route_table_id = aws_route_table.private_data.id
    subnet_id = aws_subnet.private_data[count.index].id
}