data "aws_secretsmanager_secret" "app" {
  name = "${var.project}/app/${var.environment}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  environment_variables = flatten([
    for name, value in var.environment_variables : { name : name, value : value }
  ])
  secrets = [
    for secret_name in var.secrets : {
      name : secret_name,
      valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
    }
  ]

  task_definition_name = "${var.project}-web-${var.environment}"
  container_definitions = templatefile("${path.module}/task-definitions/${var.service_json_file_name}.json", {
    ACCOUNT_ID            = data.aws_caller_identity.current.account_id
    COMMANDS              = jsonencode(var.commands)
    CONTAINER_PORT        = var.app_container_port
    CONTAINER_NAME        = var.container_name
    ECR_REPO_NAME         = var.ecr_repo_name
    ENVIRONMENT           = var.environment
    ENVIRONMENT_VARIABLES = jsonencode(local.environment_variables)
    IMAGE_TAG             = var.image_tag
    LOG_PATH              = var.log_path
    LOGGER_CONTAINER_PORT = var.logger_container_port
    LOGGER_ECR_REPO_NAME  = var.logger_ecr_repo_name
    PROJECT               = var.project
    REGION                = data.aws_region.current.name
    VOLUME_NAME           = var.volume_name
    SECRETS_LIST          = jsonencode(local.secrets)
  })
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.task_definition_name
  container_definitions    = local.container_definitions
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  volume {
    name = var.volume_name
  }

  cpu    = var.cpu
  memory = var.memory

  tags = {
    Name        = local.task_definition_name
    Project     = var.project
    Environment = var.environment
  }
}
