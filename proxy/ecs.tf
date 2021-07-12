module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.05"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids  = module.vpc.subnet_private_ids
  secrets_arns       = []
  kms_key_arns       = []
  health_check_path  = var.health_check_path
  certificate_arn    = var.ssl_certificate_arn
  allowlisted_ssh_ips = concat(
    [var.cidr_block],
    var.public_ips,
  )
}
