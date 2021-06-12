resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = var.description
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_certificate_chain_arn
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn-client-endpoint.name
    # cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn-client-endpoint.name
  }
}
