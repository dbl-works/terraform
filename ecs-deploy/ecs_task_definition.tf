resource "aws_ecs_task_definition" "main" {
  family                   = local.task_definition_name
  container_definitions    = jsonencode(local.container_definitions)
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  dynamic "volume" {
    for_each = var.volume_name == null ? [] : [{
      name = var.volume_name
    }]

    content {
      name = volume.value.name
    }
  }

  tags = {
    Name        = local.task_definition_name
    Project     = var.project
    Environment = var.environment
  }

  depends_on = [
    aws_cloudwatch_log_group.ecs_sidecar
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_sidecar" {
  count = length(var.sidecar_config)

  name              = "/${var.sidecar_config[count.index].name}/${local.name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
  }
}
