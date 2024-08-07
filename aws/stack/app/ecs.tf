data "aws_acm_certificate" "default" {
  domain      = var.domain_name
  most_recent = true
}

module "ecs" {
  source = "../../ecs"

  project        = var.project
  environment    = var.environment
  vpc_id         = module.vpc.id
  alb_subnet_ids = var.alb_subnet_type == "private" ? module.vpc.subnet_private_ids : module.vpc.subnet_public_ids
  nlb_subnet_ids = [module.vpc.subnet_public_ids[0]]
  secrets_arns = flatten([
    data.aws_secretsmanager_secret.app.arn,
    var.secret_arns
  ])

  kms_key_arns = compact(flatten(concat([
    var.grant_access_to_kms_arns,
    var.kms_app_arn,
    values(module.s3-storage)[*].kms-key-arn
  ])))

  # optional
  health_check_path           = var.health_check_path
  health_check_options        = var.health_check_options
  certificate_arn             = var.certificate_arn == null ? data.aws_acm_certificate.default.arn : var.certificate_arn
  additional_certificate_arns = var.additional_certificate_arns
  regional                    = var.regional
  name                        = var.ecs_name # custom name when convention exceeds 32 chars
  keep_alive_timeout          = var.keep_alive_timeout
  monitored_service_groups    = var.monitored_service_groups
  enable_container_insights   = var.enable_container_insights

  alb_access_logs = var.alb_access_logs
  waf_acl_arn     = var.waf_acl_arn

  allow_internal_traffic_to_ports = var.allow_internal_traffic_to_ports
  allow_alb_traffic_to_ports      = var.allow_alb_traffic_to_ports
  alb_listener_rules              = var.alb_listener_rules

  allowlisted_ssh_ips = distinct(flatten(concat([
    var.allowlisted_ssh_ips,
    var.vpc_cidr_block
  ])))

  grant_read_access_to_s3_arns = distinct(flatten(concat([
    [for arn in values(module.s3-storage)[*].arn : arn],
    var.grant_read_access_to_s3_arns
  ])))

  grant_write_access_to_s3_arns = distinct(flatten(concat([
    [for arn in values(module.s3-storage)[*].arn : arn],
    var.grant_write_access_to_s3_arns
  ])))

  grant_read_access_to_sqs_arns  = var.grant_read_access_to_sqs_arns
  grant_write_access_to_sqs_arns = var.grant_write_access_to_sqs_arns

  custom_policies                   = var.ecs_custom_policies
  enable_dashboard                  = var.enable_cloudwatch_dashboard && var.cloudwatch_dashboard_view == "simple"
  enable_xray                       = var.enable_xray
  autoscale_params                  = var.autoscale_params
  autoscale_metrics_map             = var.autoscale_metrics_map
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  service_discovery_enabled         = var.service_discovery_enabled
}

module "cloudwatch" {
  count  = var.enable_cloudwatch_dashboard == false || var.cloudwatch_dashboard_view == "simple" ? 0 : 1
  source = "../../cloudwatch"

  # Required
  region                    = var.region
  project                   = var.project
  environment               = var.environment
  cluster_names             = distinct(concat([module.ecs.ecs_cluster_name], var.cloudwatch_cluster_names))
  database_identifiers      = var.skip_rds ? [] : distinct(concat([module.rds[0].database_identifier], var.cloudwatch_database_identifiers))
  alb_arn_suffixes          = distinct(concat([module.ecs.alb_arn_suffix], var.cloudwatch_alb_arn_suffixes))
  elasticache_cluster_names = var.skip_elasticache ? [] : distinct(concat([module.elasticache[0].cluster_name], var.cloudwatch_elasticache_names))

  # optional
  metric_period                  = var.metric_period
  alarm_period                   = var.alarm_period
  alarm_evaluation_periods       = var.alarm_evaluation_periods
  sns_topic_arns                 = var.cloudwatch_sns_topic_arns
  custom_metrics                 = var.cloudwatch_custom_metrics
  db_instance_class_memory_in_gb = var.db_instance_class_memory_in_gb
  db_allocated_storage_in_gb     = var.rds_allocated_storage
  db_is_read_replica             = var.rds_is_read_replica
  datapoints_to_alarm            = var.datapoints_to_alarm
  enable_container_insights      = var.enable_container_insights
}
