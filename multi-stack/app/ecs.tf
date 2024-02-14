data "aws_acm_certificate" "default" {
  for_each = var.project_settings

  domain      = each.value.domain
  most_recent = true
}

data "aws_secretsmanager_secret" "app" {
  for_each = var.project_settings

  name = "${each.key}/app/${var.environment}"
}

data "aws_kms_key" "app" {
  for_each = var.project_settings

  key_id = "alias/${each.key}/${var.environment}/app"
}

module "ecs" {
  source = "../../ecs"

  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.id
  subnet_public_ids = module.vpc.subnet_public_ids
  secrets_arns = flatten([
    data.aws_secretsmanager_secret.app[*].arn,
    var.ecs_config.secret_arns
  ])

  kms_key_arns = compact(flatten(concat([
    module.elasticache_kms.arn,
    var.ecs_config.grant_access_to_kms_arns,
    values(module.s3-private)[*].kms-key-arn,
    values(data.aws_kms_key.app)[*].arn
  ])))

  # optional
  health_check_path           = var.ecs_config.health_check_path
  health_check_options        = var.ecs_config.health_check_options
  certificate_arn             = data.aws_acm_certificate.default[0].arn
  additional_certificate_arns = values(data.aws_acm_certificate.default)[*].arn
  keep_alive_timeout          = var.ecs_config.keep_alive_timeout
  monitored_service_groups    = var.ecs_config.monitored_service_groups
  enable_container_insights   = var.ecs_config.enable_container_insights

  allow_internal_traffic_to_ports = var.ecs_config.allow_internal_traffic_to_ports
  allow_alb_traffic_to_ports      = var.ecs_config.allow_alb_traffic_to_ports

  allowlisted_ssh_ips = distinct(flatten(concat([
    var.ecs_config.allowlisted_ssh_ips,
    var.ecs_config.vpc_cidr_block
  ])))

  grant_read_access_to_s3_arns = distinct(flatten(concat([
    [for arn in values(module.s3-private)[*].arn : arn],
    var.ecs_config.grant_read_access_to_s3_arns
  ])))

  grant_write_access_to_s3_arns = distinct(flatten(concat([
    [for arn in values(module.s3-private)[*].arn : arn],
    var.ecs_config.grant_write_access_to_s3_arns
  ])))

  grant_read_access_to_sqs_arns  = var.ecs_config.grant_read_access_to_sqs_arns
  grant_write_access_to_sqs_arns = var.ecs_config.grant_write_access_to_sqs_arns

  custom_policies                   = var.ecs_config.ecs_custom_policies
  enable_dashboard                  = var.ecs_config.enable_dashboard
  cloudwatch_logs_retention_in_days = var.ecs_config.cloudwatch_logs_retention_in_days
  service_discovery_enabled         = var.ecs_config.service_discovery_enabled
}
