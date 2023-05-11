data "aws_secretsmanager_secret" "app" {
  name = var.secrets_alias == null ? "${var.project}/app/${var.environment}" : var.secrets_alias
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name       = var.cluster_name != null ? var.cluster_name : "${var.project}-${var.environment}${var.regional ? "-${var.region}" : ""}"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  image_name = var.app_config.image_name == null ? "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.app_config.ecr_repo_name}" : var.app_config.image_name

  environment_variables = flatten([
    for name, value in var.app_config.environment_variables : { name : name, value : value }
  ])
  secrets = [
    for secret_name in var.app_config.secrets : {
      name : secret_name,
      valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
    }
  ]
  sidecar_secrets = try(var.sidecar_config.secrets, null) == null ? [] : [
    for secret_name in var.sidecar_config.secrets : {
      name : secret_name,
      valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
    }
  ]

  app_port_mappings = try(var.app_config.container_port, null) == null ? [] : [{
    containerPort : var.app_config.container_port,
    hostPort : var.app_config.container_port,
    protocol : "tcp"
  }]

  sidecar_image_name   = try(var.sidecar_config.image_name, null) == null ? "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.sidecar_config.ecr_repo_name}" : var.sidecar_config.image_name
  mount_points         = try(var.app_config.mount_points, null) == null ? [] : var.app_config.mount_points
  sidecar_mount_points = try(var.sidecar_config.mount_points, null) == null ? [] : var.sidecar_config.mount_points

  depends_on = var.sidecar_config == null ? [] : [
    {
      containerName : var.sidecar_config.name,
      condition : "START"
    }
  ]

  task_definition_name = "${var.project}-${var.app_config.name}-${var.environment}"

  app_container_definitions = templatefile("${path.module}/task-definitions/${var.container_definitions_file_name}.json", {
    COMMANDS              = jsonencode(var.app_config.commands)
    DEPENDS_ON            = jsonencode(local.depends_on)
    ECS_FARGATE_LOG_MODE  = var.ecs_fargate_log_mode
    ENVIRONMENT           = var.environment
    ENVIRONMENT_VARIABLES = jsonencode(local.environment_variables)
    IMAGE_NAME            = local.image_name
    IMAGE_TAG             = var.app_config.image_tag
    MOUNT_POINTS          = jsonencode(local.mount_points)
    NAME                  = var.app_config.name
    PORT_MAPPINGS         = jsonencode(local.app_port_mappings)
    PROJECT               = var.project
    REGION                = data.aws_region.current.name
    SECRETS_LIST          = jsonencode(local.secrets)
  })

  sidecar_container_definitions = var.sidecar_config == null ? null : templatefile("${path.module}/task-definitions/sidecar.json", {
    CONTAINER_PORT = var.sidecar_config.container_port
    IMAGE_NAME     = local.sidecar_image_name
    IMAGE_TAG      = try(var.sidecar_config.image_tag == null) == null ? var.app_config.image_tag : var.app_config.image_tag
    LOG_GROUP_NAME = try(var.sidecar_config.log_group_name, null) == null ? "/ecs/${var.project}-${var.environment}" : var.sidecar_config.log_group_name
    MOUNT_POINTS   = jsonencode(local.sidecar_mount_points)
    NAME           = var.sidecar_config.name
    PROTOCOL       = var.sidecar_config.protocol
    REGION         = local.region
    SECRETS_LIST   = jsonencode(local.sidecar_secrets)
  })

  container_definitions = [for definition in [local.app_container_definitions, local.sidecar_container_definitions] : jsondecode(definition) if definition != null]
}
