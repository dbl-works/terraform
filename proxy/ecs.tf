module "ecs" {
  # @TODO: must use this PR's release, since this PR also enables NLB's for the ECS module
  # source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.12"
  # for testing
  source = "github.com/dbl-works/terraform//ecs?ref=ba8e35ce9c38fb7303e9cd6bdfce51e6f1f15bee"

  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.id
  subnet_private_ids  = module.vpc.subnet_private_ids
  subnet_public_ids   = module.vpc.subnet_private_ids
  secrets_arns        = [] # do we need any?
  kms_key_arns        = [module.kms-key.arn]
  allowlisted_ssh_ips = [var.cidr_block]
  # allowlisted_ssh_ips = setunion(
  #   [var.cidr_block],
  #   var.public_ips,
  # )
}
