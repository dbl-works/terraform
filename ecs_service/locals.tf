data "aws_secretsmanager_secret" "app" {
  name = var.secrets_alias == null ? "${var.project}/app/${var.environment}" : var.secrets_alias
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

  app_port_mappings = var.app_container_port == null ? [] : [{
    containerPort : var.app_container_port,
    hostPort : var.app_container_port,
    protocol : "tcp"
  }]
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.name
  image_name        = var.app_image_name == null ? "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.ecr_repo_name}" : var.app_image_name
  logger_image_name = var.with_logger && var.logger_image_name == null ? "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.logger_ecr_repo_name}" : var.logger_image_name

  task_definition_name = "${var.project}-${var.container_name}-${var.environment}"
  app_container_definitions = templatefile("${path.module}/task-definitions/${var.service_json_file_name}.json", {
    APP_PORT_MAPPINGS     = jsonencode(local.app_port_mappings)
    COMMANDS              = jsonencode(var.commands)
    CONTAINER_NAME        = var.container_name
    ECR_REPO_NAME         = var.ecr_repo_name
    ENVIRONMENT           = var.environment
    ENVIRONMENT_VARIABLES = jsonencode(local.environment_variables)
    IMAGE_NAME            = local.image_name
    IMAGE_TAG             = var.image_tag
    LOG_PATH              = var.log_path
    PROJECT               = var.project
    REGION                = data.aws_region.current.name
    SECRETS_LIST          = jsonencode(local.secrets)
    VOLUME_NAME           = var.volume_name
    MOUNT_POINTS = var.with_logger ? [
      {
        sourceVolume : var.volume_name,
        containerPath : "/app/${var.log_path}"
      }
    ] : []
    DEPENDS_ON = var.with_logger ? [
      {
        containerName : "logger",
        condition : "START"
      }
    ] : []
  })

  logger_container_definitions = var.with_logger ? templatefile("${path.module}/task-definitions/logger.json", {
    ENVIRONMENT           = var.environment
    IMAGE_NAME            = local.logger_image_name
    IMAGE_TAG             = var.image_tag
    LOG_PATH              = var.log_path
    LOGGER_CONTAINER_PORT = var.logger_container_port
    LOGGER_IMAGE_NAME     = local.logger_image_name
    PROJECT               = var.project
    REGION                = local.region
    VOLUME_NAME           = var.volume_name
  }) : ""

  container_definitions = var.with_logger ? [
    local.app_container_definitions, local.logger_container_definitions
  ] : [local.app_container_definitions]
}
