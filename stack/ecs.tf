module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=${var.module_version}"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids  = module.vpc.subnet_public_ids
  secrets_arns = [
    module.secrets["app"].arn
  ]
  kms_key_arns = flatten(concat([
    module.kms-key.arn,
    module.s3-storage.kms-key-arn
  ]))

  # optional
  health_check_path = "/livez"
  # requires a `certificate` module to be created separately
  certificate_arn = module.certificate.arn

  allow_internal_traffic_to_ports = var.allow_internal_traffic_to_ports

  allowlisted_ssh_ips = var.allowlisted_ssh_ips

  grant_read_access_to_s3_arns = []
  grant_write_access_to_s3_arns = [
    "${module.s3-storage.arn}/*",
  ]

  grant_read_access_to_sqs_arns  = []
  grant_write_access_to_sqs_arns = []

  custom_policies = var.ecs_custom_policies

  depends_on = [
    module.certificate.arn,
    module.kms-key.arn,
    module.s3-storage.kms-key-arn
  ]
}
