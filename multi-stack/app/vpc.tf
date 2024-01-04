module "vpc" {
  source = "../../vpc"

  environment        = var.environment
  project            = var.project
  availability_zones = var.vpc_availability_zones

  # optional
  cidr_block = var.vpc_cidr_block
}
