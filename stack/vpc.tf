module "vpc" {
  source = "github.com/dbl-works/terraform//vpc?ref=v2021.11.09"

  account_id = var.account_id
  project = var.project
  environment = var.environment
  region = var.region
  cidr_block = var.cidr_block
  availability_zones = var.availability_zones
}
