module "vpc" {
  source = "../vpc"

  availability_zones = [local.availability_zone]
  environment        = var.environment
  project            = var.project
  cidr_block         = var.cidr_block
}
