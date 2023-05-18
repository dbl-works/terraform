data "aws_secretsmanager_secret" "app" {
  name = var.secrets_alias == null ? "${var.project}/app/${var.environment}" : var.secrets_alias
}

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
  container_definitions = templatefile("${path.module}/task-definitions/main.json", {
    COMMANDS              = jsonencode(var.commands)
    ECS_FARGATE_LOG_MODE  = var.ecs_fargate_log_mode
    ENVIRONMENT_VARIABLES = jsonencode(var.environment_variables)
    IMAGE_NAME            = var.image_name
    IMAGE_TAG             = var.image_tag
    NAME                  = var.name
    PROJECT               = var.project
    ENVIRONMENT           = var.environment
    REGION                = local.region
    SECRETS_LIST          = jsonencode(local.secrets)
  })

  secrets = [
    for secret_name in var.secrets : {
      name : secret_name,
      valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
    }
  ]
}
