data "aws_acm_certificate" "default" {
  for_each = var.project_settings

  domain      = each.value.domain
  most_recent = true
}

module "ecs" {
  for_each = var.project_settings

  source = "../../ecs"

  project           = each.key
  environment       = var.environment
  vpc_id            = module.vpc.id
  subnet_public_ids = module.vpc.subnet_public_ids
  secrets_arns = flatten([
    data.aws_secretsmanager_secret.app[each.key].arn,
    var.secret_arns
  ])

  kms_key_arns = compact(flatten(concat([
    var.grant_access_to_kms_arns,
    var.kms_app_arn,
    # TODO: @sam
    # values(module.s3-storage)[*].kms-key-arn
  ])))

  # optional
  health_check_path           = var.health_check_path
  health_check_options        = var.health_check_options
  certificate_arn             = data.aws_acm_certificate.default[each.key].arn
  additional_certificate_arns = var.additional_certificate_arns
  regional                    = each.value.regional
  name                        = each.value.ecs_name # custom name when convention exceeds 32 chars
  keep_alive_timeout          = var.keep_alive_timeout
  monitored_service_groups    = var.monitored_service_groups
  enable_container_insights   = var.enable_container_insights

  allow_internal_traffic_to_ports = each.value.allow_internal_traffic_to_ports
  allow_alb_traffic_to_ports      = each.value.allow_alb_traffic_to_ports
  alb_listener_rules              = each.value.alb_listener_rules

  allowlisted_ssh_ips = distinct(flatten(concat([
    var.allowlisted_ssh_ips,
    var.vpc_cidr_block
  ])))

  grant_read_access_to_s3_arns = distinct(flatten(concat([
    # [for arn in values(module.s3-storage)[*].arn : arn],
    each.value.grant_read_access_to_s3_arns
  ])))

  grant_write_access_to_s3_arns = distinct(flatten(concat([
    # [for arn in values(module.s3-storage)[*].arn : arn],
    each.value.grant_write_access_to_s3_arns
  ])))

  grant_read_access_to_sqs_arns  = each.value.grant_read_access_to_sqs_arns
  grant_write_access_to_sqs_arns = each.value.grant_write_access_to_sqs_arns

  custom_policies                   = each.value.ecs_custom_policies
  enable_dashboard                  = var.enable_cloudwatch_dashboard && var.cloudwatch_dashboard_view == "simple"
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  service_discovery_enabled         = var.service_discovery_enabled
}
