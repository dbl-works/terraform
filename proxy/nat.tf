module "nat" {
  source = "github.com/dbl-works/terraform//nat?ref=v2021.07.13"

  project     = var.project
  environment = var.environment
  public_ips  = [var.public_ip]

  vpc_id             = module.vpc.id
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids
}
