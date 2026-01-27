output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
}

output "vpc_cidr" {
    description = "VPC CIDR block"
    value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
    description = "List of public subnet IDs"
    value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
    description = "List of private app subnet IDs"
    value       = aws_subnet.private[*].id
}

output "private_data_subnet_ids" {
    description = "List of private data subnet IDs"
    value       = aws_subnet.private_data[*].id
}

output "nat_gateway_ips" {
    description = "NAT Gateway public IPs"
    value       = aws_eip.nat[*].public_ip
}