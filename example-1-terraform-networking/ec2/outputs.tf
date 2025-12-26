output "ubuntu_EC2_id" {
    value = aws_instance.ubuntu_instance.id
}

output "ubuntu_EC2_instance_public_ip" {
    value = aws_instance.ubuntu_instance.public_ip
}