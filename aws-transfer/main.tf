resource "aws_transfer_server" "main" {
  domain                 = var.domain
  protocols              = var.protocols
  identity_provider_type = var.identity_provider_type
  endpoint_type          = var.endpoint_type

  tags = {
  }
}
