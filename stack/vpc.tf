module "vpc" {
  source = "github.com/dbl-works/terraform//vpc?${var.module_version}"

  account_id         = var.account_id
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  environment        = var.environment
  project            = var.project

  # optional
  region     = var.region
  cidr_block = "10.0.0.0/16"
}
