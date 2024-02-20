module "vpc" {
  source = "../../vpc"

  environment        = var.environment
  project            = var.project
  availability_zones = var.vpc_config.availability_zones

  # optional
  cidr_block = var.vpc_config.cidr_block
}
