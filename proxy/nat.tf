module "nat" {
  # source = "github.com/dbl-works/terraform//nat?ref=v2021.07.09"
  # for testing:
  source = "github.com/dbl-works/terraform//nat?ref=c62fc41c7d418cbf42922bc4db752d0b7eb1fe41"

  project     = var.project
  environment = var.environment
  public_ips  = var.public_ips

  vpc_id             = module.vpc.id
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids
}
