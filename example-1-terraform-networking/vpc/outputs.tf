output "vpc_id" {
    value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
    value = aws_subnet.my_vpc_public_subnets.*.id
}

output "private_subnet_ids" {
    value = aws_subnet.my_vpc_private_subnets.*.id
}