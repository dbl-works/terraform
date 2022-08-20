data "aws_acm_certificate" "default" {
  domain = var.domain_name
}

module "ecs" {
  source = "../../ecs"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids  = module.vpc.subnet_public_ids
  secrets_arns = flatten([
    data.aws_secretsmanager_secret.app.arn,
    var.secret_arns
  ])

  kms_key_arns = flatten(concat([
    var.kms_app_arn,
    values(module.s3-storage)[*].kms-key-arn
  ]))

  # optional
  health_check_path = var.health_check_path
  certificate_arn   = data.aws_acm_certificate.default.arn
  regional          = var.regional
  name              = var.ecs_name # custom name when convention exceeds 32 chars
  region            = var.region   # used for e.g CloudWatch metrics

  allow_internal_traffic_to_ports = var.allow_internal_traffic_to_ports

  allowlisted_ssh_ips = distinct(flatten(concat([
    var.allowlisted_ssh_ips,
    var.vpc_cidr_block
  ])))

  grant_read_access_to_s3_arns = distinct(flatten(concat([
    [for arn in values(module.s3-storage)[*].arn : "${arn}/*"],
    var.grant_read_access_to_s3_arns
  ])))

  grant_write_access_to_s3_arns = distinct(flatten(concat([
    [for arn in values(module.s3-storage)[*].arn : "${arn}/*"],
    var.grant_write_access_to_s3_arns
  ])))

  grant_read_access_to_sqs_arns  = var.grant_read_access_to_sqs_arns
  grant_write_access_to_sqs_arns = var.grant_write_access_to_sqs_arns

  custom_policies  = var.ecs_custom_policies
  enable_dashboard = var.cloudwatch_dashboard_view == "simple"
}

module "cloudwatch" {
  count  = var.cloudwatch_dashboard_view == "simple" ? 0 : 1
  source = "../../cloudwatch"

  # Required
  region                   = var.region
  project                  = var.project
  environment              = var.environment
  cluster_name             = local.name
  database_name            = module.rds.database_name
  alb_arn_suffix           = module.ecs.alb_arn_suffix
  elasticache_cluster_name = module.elasticache.cluster_name

  # optional
  metric_period            = var.metric_period
  alarm_period             = var.alarm_period
  alarm_evaluation_periods = var.alarm_evaluation_periods
  slack_channel_id         = var.slack_channel_id
  slack_workspace_id       = var.slack_workspace_id
  sns_topic_arn            = var.slack_sns_topic_arn
}
