module "vpc" {
  source = "../vpc"

  account_id         = var.account_id
  availability_zones = local.availability_zone
  environment        = var.environment
  project            = var.project
  region             = var.region
  cidr_block         = var.cidr_block
}
