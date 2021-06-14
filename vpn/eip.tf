resource "aws_eip_association" "eip_assoc" {
  network_interface_id = aws_network_interface.main.id
  allow_reassociation  = true
  allocation_id        = var.eip_id
}
