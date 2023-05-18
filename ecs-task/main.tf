data "aws_iam_role" "main" {
  name = var.aws_iam_role_name == null ? "ecs-task-execution-${var.project}-${var.environment}" : var.aws_iam_role_name
}

resource "aws_ecs_task_definition" "task" {
  family = "${var.project}-${var.environment}-task-${var.name}"
  container_definitions = templatefile("${path.module}/task-definitions/main.json", {
    COMMANDS              = jsonencode(var.commands)
    ECS_FARGATE_LOG_MODE  = var.ecs_fargate_log_mode
    ENVIRONMENT_VARIABLES = jsonencode(local.environment_variables)
    IMAGE_NAME            = var.image_name
    IMAGE_TAG             = var.image_tag
    NAME                  = var.name
    PROJECT               = var.project
    ENVIRONMENT           = var.environment
    REGION                = local.region
    SECRETS_LIST          = jsonencode(local.secrets)
  })

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
}

resource "aws_cloudwatch_log_group" "tasks" {
  count = var.enable_cloudwatch_log ? 1 : 0

  name              = "/ecs/${var.project}-${var.environment}/task"
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Name        = "${var.project}-${var.environment}-task"
    Project     = var.project
    Environment = var.environment
  }
}
