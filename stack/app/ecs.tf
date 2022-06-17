module "ecs-kms-key" {
  source = "../../kms-key"

  # Required
  environment = var.environment
  project     = var.project
  alias       = "ecs"
  description = "kms key for ${var.project} ECS"

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}

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
    module.ecs-kms-key.arn,
    values(module.s3-storage)[*].kms-key-arn
  ]))

  # optional
  health_check_path = var.health_check_path
  certificate_arn   = data.aws_acm_certificate.default.arn

  allow_internal_traffic_to_ports = var.allow_internal_traffic_to_ports

  allowlisted_ssh_ips = var.allowlisted_ssh_ips

  grant_read_access_to_s3_arns = var.grant_read_access_to_s3_arns
  grant_write_access_to_s3_arns = flatten(concat([
    [for arn in values(module.s3-storage)[*].arn : "${arn}/*"],
    var.grant_write_access_to_s3_arns
  ]))

  grant_read_access_to_sqs_arns  = var.grant_read_access_to_sqs_arns
  grant_write_access_to_sqs_arns = var.grant_write_access_to_sqs_arns

  custom_policies = var.ecs_custom_policies
}
