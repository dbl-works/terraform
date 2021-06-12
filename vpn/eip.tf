resource "aws_eip_association" "eip_assoc" {
  network_interface_id = "123" # should be auto-generated when creating a client-vpn-endpoint. How do we get it?
  allow_reassociation  = true
  allocation_id        = var.eip_id
}
