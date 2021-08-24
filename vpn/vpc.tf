module "vpc" {
  source = "github.com/dbl-works/terraform//vpc?ref=v2021.07.30"

  account_id         = var.account_id
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  environment        = var.environment
  project            = var.project
  region             = var.region
  cidr_block         = var.cidr_block
}
