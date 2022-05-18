
module "rds" {
  source = "github.com/dbl-works/terraform//rds?ref=${var.module_version}"

  project                    = var.project
  environment                = var.environment
  account_id                 = var.account_id
  region                     = var.region
  vpc_id                     = module.vpc.id
  password                   = local.credentials.db_root_password
  kms_key_arn                = module.kms-key.arn
  subnet_ids                 = module.vpc.subnet_private_ids
  allow_from_security_groups = [module.ecs.ecs_security_group_id]

  # optional
  username = local.credentials.db_username
  # TODO: Larger for production
  instance_class = "db.t3.micro"
  # TODO: Check on the list of existing engine version
  engine_version = "13.2"
  # TODO: Do we need so much for staging?
  allocated_storage = 100
  # TODO: true for production?
  multi_az = false
}
