data "aws_iam_role" "main" {
  name = var.aws_iam_role_name == null ? "ecs-task-execution-${var.project}-${var.environment}" : var.aws_iam_role_name
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project}-${var.environment}-task-${var.name}"
  container_definitions    = jsonencode(local.container_definitions)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
}
