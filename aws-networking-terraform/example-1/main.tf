terraform {
    required_version = ">=1.6"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
    region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name        = "my-first-vpc"
        Environment = "learning"
        ManagedBy   = "terraform"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    
    tags = {
        Name = "my-first-igw"
    }
}

# Public Subnet
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "public-subnet-1a"
        Type = "public"
    }
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        gateway_id = aws_internet_gateway.main.id
        cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route_table_association" "public" {
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public.id
}

# Security Group
resource "aws_security_group" "web_server" {
    name = "web-server-sg"
    vpc_id = aws_vpc.main.id

    ingress {
        protocol = "tcp"
        to_port = 80
        from_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP from anywhere"
    }

    ingress {
        description = "SSH from my IP"
        protocol = "tcp"
        to_port = 22
        from_port = 22
        cidr_blocks = [ "49.36.181.223/32" ]
    }

    egress {
        description = "Allow all outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "web-server-sg"
    }
}

output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
}

output "public_subnet_id" {
    description = "Public Subnet ID"
    value       = aws_subnet.public.id
}

output "security_group_id" {
    description = "Security Group ID"
    value       = aws_security_group.web_server.id
}