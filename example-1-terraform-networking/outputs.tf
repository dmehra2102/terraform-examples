output "availability_zones" {
    value = data.aws_availability_zones.availability_zones.names
}

output "security_groups_name" {
    value = [ module.vpc.allow_only_ssh_ipv4_sg_name, module.vpc.allow_ssh_http_https_ipv4_sg_name]
}