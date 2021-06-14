resource "aws_security_group" "full_internet_access" {
  name        = "full-internet-access"
  description = "Allow internet traffic for the VPN"
  vpc_id      = var.vpc_id

  # find the rules at: vpn/aws-security-group-rules.tf

  tags = {
    Name        = "full-internet-access"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_ec2_client_vpn_network_association" "internet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = var.vpc_public_subnet_id
  security_groups        = [aws_security_group.full_internet_access.id]
}
