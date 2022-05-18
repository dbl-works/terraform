module "nat" {
  source = "github.com/dbl-works/terraform//nat?ref=${var.module_version}"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids
  public_ips         = var.public_ips
}
