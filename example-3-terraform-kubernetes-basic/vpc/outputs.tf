output "vpc_id" {
    value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
    value = aws_subnet.my_vpc_public_subnets.*.id
}

output "private_subnet_ids" {
    value = aws_subnet.my_vpc_private_subnets.*.id
}

output "allow_only_ssh_ipv4_sg_id" {
    value = aws_security_group.allow_only_ssh_ipv4.id
}

output "allow_ssh_http_https_ipv4_sg_id" {
    value = aws_security_group.allow_ssh_http_https_ipv4.id
}

output "allow_only_ssh_ipv4_sg_name" {
    value = aws_security_group.allow_only_ssh_ipv4.name
}

output "allow_ssh_http_https_ipv4_sg_name" {
    value = aws_security_group.allow_ssh_http_https_ipv4.name
}