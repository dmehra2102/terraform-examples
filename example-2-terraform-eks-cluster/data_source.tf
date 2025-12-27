data "aws_availability_zones" "availability_zones" {
    region = var.aws_region
    filter {
        name = "opt-in-status"
        values =[ "opt-in-not-required" ]
    }
}

data "aws_ami" "ubuntu_ami" {
    region = var.aws_region
    most_recent = true
    owners = ["amazon"]
    

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
}