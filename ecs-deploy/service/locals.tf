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
  app_port_mappings = try(var.app_config.container_port, null) == null ? [] : [{
    containerPort : var.app_config.container_port,
    hostPort : var.app_config.container_port,
    name : var.app_config.name,
    protocol : "tcp",
  }]

  mount_points = try(var.app_config.mount_points, null) == null ? [] : var.app_config.mount_points
  depends_on = [for config in var.sidecar_config : {
    containerName : config.name,
    condition : "START"
  }]

  task_definition_name = "${var.project}-${var.app_config.name}-${var.environment}"

  app_container_definitions = templatefile("${path.module}/task-definitions/${var.container_definitions_file_name}.json", {
    COMMANDS              = jsonencode(var.app_config.commands)
    DEPENDS_ON            = jsonencode(local.depends_on)
    ECS_FARGATE_LOG_MODE  = var.ecs_fargate_log_mode
    ENVIRONMENT           = var.environment
    ENVIRONMENT_VARIABLES = jsonencode(local.environment_variables)
    IMAGE_NAME            = local.image_name
    IMAGE_TAG             = var.app_config.image_tag
    LOG_GROUP_NAME        = "/custom/${var.project}/${var.environment}/ecs-${var.app_config.name}"
    MOUNT_POINTS          = jsonencode(local.mount_points)
    NAME                  = var.app_config.name
    PORT_MAPPINGS         = jsonencode(local.app_port_mappings)
    PROJECT               = var.project
    REGION                = data.aws_region.current.name
    SECRETS_LIST          = jsonencode(local.secrets)
  })

  sidecar_container_definitions = [for config in var.sidecar_config : templatefile("${path.module}/task-definitions/sidecar.json", {
    CONTAINER_PORT = config.container_port
    IMAGE_NAME     = try(config.image_name, null) == null ? "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${config.ecr_repo_name}" : config.image_name
    IMAGE_TAG      = try(config.image_tag == null) == null ? var.app_config.image_tag : config.image_tag
    LOG_GROUP_NAME = "/custom/${var.project}/${var.environment}/ecs-${config.name}"
    MOUNT_POINTS   = jsonencode(config.mount_points)
    NAME           = config.name
    PROTOCOL       = config.protocol
    REGION         = local.region
    SECRETS_LIST = jsonencode([
      for secret_name in config.secrets : {
        name : secret_name,
        valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
      }
    ])
  })]

  container_definitions = [for definition in flatten([local.app_container_definitions, local.sidecar_container_definitions]) : jsondecode(definition) if definition != null]
}
