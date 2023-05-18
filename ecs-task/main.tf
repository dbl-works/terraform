locals {
  name = var.cluster_name != null ? var.cluster_name : "${var.project}-${var.environment}${var.regional ? "-${local.region}" : ""}"
}

data "aws_iam_role" "main" {
  name = "ecs-task-execution-${local.name}"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${project}-${var.environment}-task-${var.name}"
  container_definitions    = jsonencode(local.container_definitions)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
}
