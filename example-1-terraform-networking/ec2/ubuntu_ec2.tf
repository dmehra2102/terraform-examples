resource "aws_instance" "ubuntu_instance" {
    ami                    = var.instance_ami
    instance_type          = var.instance_type
    subnet_id              = var.subnet_id
    key_name               = var.access_key_name
    vpc_security_group_ids = toset(var.security_groups)

    tags = {
        Name = "ubuntu_ec2_instance"
    }
}
