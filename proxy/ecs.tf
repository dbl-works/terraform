module "ecs" {
  # @TODO: must use this PR's release, since this PR also enables NLB's for the ECS module
  # source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.12"
  # for testing
  source = "github.com/dbl-works/terraform//ecs?ref=63e2f0cab2ae06f8e8355cae2a3976ceed893de8"

  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.id
  subnet_private_ids  = module.vpc.subnet_private_ids
  subnet_public_ids   = module.vpc.subnet_private_ids
  secrets_arns        = []
  kms_key_arns        = []
  health_check_path   = var.health_check_path
  certificate_arn     = var.ssl_certificate_arn
  allowlisted_ssh_ips = [var.cidr_block]
  # allowlisted_ssh_ips = setunion(
  #   [var.cidr_block],
  #   var.public_ips,
  # )
}
