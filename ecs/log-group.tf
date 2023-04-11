resource "aws_cloudwatch_log_group" "ecs-app" {
  name              = "/ecs/${local.name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
