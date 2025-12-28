resource "aws_security_group" "allow_only_ssh_ipv4" {
    name = "allow-only-ssh-ipv4"
    description = "Allow only SSH inbound traffic"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        to_port = 22
        from_port = 22
        protocol = "tcp"
        description = "Allow SSH inbound traffic"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_ssh_http_https_ipv4" {
    vpc_id = aws_vpc.my_vpc.id
    name = "allow-ssh-http-https-ipv4"
    description = "Allow SSH, HTTP, HTTPs inbound traffic"

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        to_port = 22
        from_port = 22
        protocol = "tcp"
        description = "Allow SSH inbound traffic"
    }

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        to_port = 80
        from_port = 80
        protocol = "tcp"
        description = "Allow HTTP inbound traffic"
    }

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        to_port = 443
        from_port = 443
        protocol = "tcp"
        description = "Allow HTTPs inbound traffic"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}