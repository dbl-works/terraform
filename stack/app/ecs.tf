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

  custom_policies = var.ecs_custom_policies
}
