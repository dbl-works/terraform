module "vpc" {
  source = "github.com/dbl-works/terraform//vpc?ref=v2021.07.12"

  account_id         = var.account_id
  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  environment        = var.environment
  project            = var.project
}
