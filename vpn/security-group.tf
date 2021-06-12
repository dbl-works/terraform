resource "aws_security_group" "full_internet_access" {
  name        = "full-internet-access"
  description = "Allow internet traffic for the VPN"
  vpc_id      = var.vpc_id

  ingress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "full-internet-access"
  }
}

resource "aws_ec2_client_vpn_network_association" "internet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = var.public_subnet_id
  security_groups        = [aws_security_group.full_internet_access.id]
}
