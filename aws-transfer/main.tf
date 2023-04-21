resource "aws_transfer_server" "main" {
  domain                 = var.server_domain
  protocols              = var.protocols
  identity_provider_type = var.identity_provider_type
  endpoint_type          = var.endpoint_type
  logging_role           = aws_iam_role.logging.arn

  dynamic "endpoint_details" {
    for_each = var.endpoint_details == null ? [] : [var.endpoint_details]
    content {
      address_allocation_ids = endpoint_details.value.address_allocation_ids
      subnet_ids             = endpoint_details.value.subnet_ids
      vpc_id                 = endpoint_details.value.vpc_id
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
