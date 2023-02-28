resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/lambda/${var.function_name}"
  retention_in_days = 90

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
