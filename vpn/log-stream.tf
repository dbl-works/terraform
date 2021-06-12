# resource "aws_cloudwatch_log_stream" "vpn-client-endpoint" {
#   name           = "/vpn/${var.project}/${var.environment}/stream"
#   log_group_name = aws_cloudwatch_log_group.vpn-client-endpoint.name
# }
