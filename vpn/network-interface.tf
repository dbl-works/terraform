resource "aws_network_interface" "main" {
  subnet_id       = var.vpc_public_subnet_id
  security_groups = [aws_security_group.full_internet_access.id]
}
