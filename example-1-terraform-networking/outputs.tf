output "availability_zones" {
    value = data.aws_availability_zones.availability_zones.names
}