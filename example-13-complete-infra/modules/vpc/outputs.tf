output "vpc_id" {
    value       = aws_vpc.this.id
    description = "VPC ID."
}

output "public_subnet_ids" {
    value       = [for s in aws_subnet.public : s.id]
    description = "Public subnet IDs."
}

output "private_subnet_ids" {
    value       = [for s in aws_subnet.private : s.id]
    description = "Private subnet IDs."
}

output "endpoint_sg_id" {
    value       = aws_security_group.endpoints.id
    description = "Security group for interface endpoints."
}
