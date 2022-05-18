module "vpc" {
  source = "github.com/dbl-works/terraform//vpc?${var.module_version}"

  account_id         = var.account_id
  availability_zones = var.vpc_availability_zones
  environment        = var.environment
  project            = var.project

  # optional
  region     = var.region
  cidr_block = var.vpc_cidr_block
}
