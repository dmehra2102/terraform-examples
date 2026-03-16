output "vpc_id"              { value = aws_vpc.main.id}
output "public_subnet_ids"   { value = aws_subnet.public[*].id }
output "private_subnet_ids"  { value = aws_subnet.private[*].id }
output "database_subnet_ids" { value = aws_subnet.database[*].id }
output "vpc_cidr_block"      { value = aws_vpc.main.cidr_block }
output "nat_gateway_ips"     { value = aws_eip.nat[*].public_ip }
output "vpc_endpoint_sg_id"  { value = aws_security_group.vpc_endpoints.id }
