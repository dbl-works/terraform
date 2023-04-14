resource "aws_transfer_server" "main" {
  domain                 = var.server_domain
  protocols              = var.protocols
  identity_provider_type = var.identity_provider_type
  endpoint_type          = var.endpoint_type

  dynamic "endpoint_details" {
    for_each = var.endpoint_details == null ? [] : [var.endpoint_details]
    content {
      address_allocation_ids = endpoint_details.address_allocation_ids
      subnet_ids             = endpoint_details.subnet_ids
      vpc_id                 = endpoint_details.vpc_id
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
