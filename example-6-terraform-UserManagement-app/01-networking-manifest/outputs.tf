output "vpc_name" {
    value = aws_vpc.my_vpc.id
    description = "The ID of the VPC"
}

output "availability_zones" {
    value = data.aws_availability_zones.availability_zones.names
    description = "The list of availability zones"
}

output "public_subnet_ids" {
    value = local.public_subnet_ids
    description = "The list of all public subnet ids"
}

output "private_subnet_ids" {
    value = local.private_subnet_ids
    description = "The list of all private subnet ids"
}

output "vpc_security_groups" {
    value = [
        aws_security_group.allow_ssh_http_https_ipv4.name,
        aws_security_group.allow_only_ssh_ipv4.name
    ]
    description = "The list of Security group for VPC"
}