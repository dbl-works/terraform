resource "aws_ecs_task_definition" "main" {
  family                   = local.task_definition_name
  container_definitions    = jsonencode(local.container_definitions)
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  # We only need volume if logger is enabled
  dynamic "volume" {
    for_each = var.with_logger ? [{
      name = var.volume_name
    }] : []

    content {
      name = volume.value.name
    }
  }

  tags = {
    Name        = local.task_definition_name
    Project     = var.project
    Environment = var.environment
  }
}
