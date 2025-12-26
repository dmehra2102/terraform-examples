resource "aws_security_group" "allow_only_ssh_ipv4" {
    name = "allow_only_ssh_ipv4"
    vpc_id = aws_vpc.my_vpc.id
    description = "Allow SSH traffic from any ipV4 address."

    ingress {
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All SSH inbound traffic"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_ssh_http_https_ipv4" {
    name = "allow_ssh_http_https_ipv4"
    vpc_id = aws_vpc.my_vpc.id
    description = "Allow SSH, HTTP and HTTPs traffic from all ipV4 address."

    ingress {
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All SSH inbound traffic"
    }

    ingress {
        to_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All HTTP inbound traffic"
    }

    ingress {
        to_port = 443
        from_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All HTTPs inbound traffic"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}