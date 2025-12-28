locals {
    public_subnet_ids = aws_subnet.my_vpc_public_subnets.*.id
    private_subnet_ids = aws_subnet.my_vpc_private_subnets.*.id
}