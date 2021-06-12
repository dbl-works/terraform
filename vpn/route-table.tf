# we need to create routes for the VPC and the Internet

resource "aws_ec2_client_vpn_route" "vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = var.vpc_general_network_cidr
  target_vpc_subnet_id   = var.public_subnet_id
}

resource "aws_ec2_client_vpn_route" "internet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = var.public_subnet_id
}
