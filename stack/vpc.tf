module "vpc" {
  source = "../vpc"

  account_id         = var.account_id
  environment        = var.environment
  project            = var.project
  availability_zones = var.vpc_availability_zones

  # optional
  region     = var.region
  cidr_block = var.vpc_cidr_block
}
