resource "aws_cloudwatch_log_group" "vpn-client-endpoint" {
  name              = "/vpn/${var.project}/${var.environment}/group"
  retention_in_days = var.log_retention_in_days

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
