module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.30"

  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.id
  subnet_private_ids  = module.vpc.subnet_private_ids
  subnet_public_ids   = module.vpc.subnet_private_ids
  secrets_arns        = [] # do we need any?
  kms_key_arns        = [module.kms-key.arn]
  allowlisted_ssh_ips = [var.cidr_block]
  certificate_arn     = var.certificate_arn
}
