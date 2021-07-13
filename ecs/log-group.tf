resource "aws_cloudwatch_log_group" "ecs-app" {
  name              = "/ecs/${var.project}/app/${var.environment}"
  retention_in_days = 3

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
