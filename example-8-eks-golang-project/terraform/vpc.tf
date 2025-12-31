resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.project_name}-vpc"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.project_name}-igw"
    }
}

# Two Public Subnets
resource "aws_subnet" "public" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name                        = "${var.project_name}-public-subnet-${count.index + 1}"
        Type                        = "Public"
        "kubernetes.io/role/elb"    = "1"
    }
}

# Two Private Subnets (For EKS Nodes)
resource "aws_subnet" "private" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name                                = "${var.project_name}-private-subnet-${count.index + 1}"
        Type                                = "Private"
        "kubernetes.io/role/internal-elb"   = "1"
    }
}

# Database Subnets
resource "aws_subnet" "database" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.project_name}-database-subnet-${count.index + 1}"
        Type = "Database"
    }
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
    count  = length(var.public_subnet_cidrs)
    domain = "vpc"

    tags = {
        Name = "${var.project_name}-eip-nat-${count.index + 1}"
    }

    depends_on = [aws_internet_gateway.main]
}

# NAT Gateway per AZ's (High Availability)
resource "aws_nat_gateway" "main" {
    count = length(aws_subnet.public)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id

    tags = {
        Name = "${var.project_name}-nat-${count.index + 1}"
    }

    depends_on = [ aws_internet_gateway.main ]
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "${var.project_name}-public-rt"
    }
}

# Pubic Route Table Association
resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id
}

# Private Route Table (Per AZ's)
resource "aws_route_table" "private" {
    count = length(aws_subnet.private)
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = {
        Name = "${var.project_name}-private-rt-${count.index + 1}"
    }
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
    count          = length(aws_subnet.private)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

# Database Route Table
resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name}-database-rt"
    }
}

# Database Route Table Associations
resource "aws_route_table_association" "database" {
    count          = length(aws_subnet.database)
    subnet_id      = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}