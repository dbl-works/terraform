module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.11.09"

  project = var.project
  environment = var.environment
  vpc_id = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids = module.vpc.subnet_public_ids
  certificate_arn = "..."
  health_check_path = "/livez"
  # secrets_arns = [
  #   aws_secretsmanager_secret.app.arn,
  # ]
  kms_key_arns = [
    module.kms-key-app.arn,
  ]
  allowlisted_ssh_ips = flatten([
    [var.cidr_block], # required for health checks
    var.allowlisted_ssh_ips,
  ])
  grant_read_access_to_s3_arns = [
    "arn:aws:s3:::storage.${local.domain_name}/*"
  ]
  grant_write_access_to_s3_arns = [
    "arn:aws:s3:::storage.${local.domain_name}/*"
  ]
}
