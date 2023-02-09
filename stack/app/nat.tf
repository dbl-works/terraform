module "nat" {
  count = length(var.public_ips) > 0 ? 1 : 0

  source = "../../nat"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids
  public_ips         = var.public_ips
}
