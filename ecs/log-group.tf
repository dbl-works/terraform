resource "aws_cloudwatch_log_group" "ecs-app" {
  name              = "/ecs/${var.name}"
  retention_in_days = 90

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
