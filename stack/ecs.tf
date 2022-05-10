module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=${var.module_version}"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids  = module.vpc.subnet_private_ids
  secrets_arns       = []
  kms_key_arns       = []

  # optional
  health_check_path = "/healthz"
  certificate_arn   = module.ssl-certificate.arn # requires a `certificate` module to be created separately

  allow_internal_traffic_to_ports = []

  allowlisted_ssh_ips = [
    local.cidr_block,
    "XX.XX.XX.XX/32", # e.g. a VPN
  ]

  grant_read_access_to_s3_arns  = []
  grant_write_access_to_s3_arns = []

  grant_read_access_to_sqs_arns  = []
  grant_write_access_to_sqs_arns = []

  custom_policies = []
}
