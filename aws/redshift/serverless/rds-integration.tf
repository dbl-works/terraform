resource "aws_rds_integration" "main" {
  integration_name = "${local.name}-rds-integration"
  source_arn       = var.source_rds_arn
  target_arn       = aws_redshiftserverless_namespace.main.arn

  tags = {
    Name        = "${local.name}-rds-integration"
    Project     = var.project
    Environment = var.environment
  }
}
