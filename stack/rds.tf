module "rds" {
  source = "../rds"

  project                    = var.project
  environment                = var.environment
  account_id                 = var.account_id
  region                     = var.region
  vpc_id                     = module.vpc.id
  password                   = local.credentials.db_root_password
  kms_key_arn                = module.rds-kms-key.arn
  subnet_ids                 = module.vpc.subnet_private_ids
  allow_from_security_groups = [module.ecs.ecs_security_group_id]

  # optional
  username          = local.credentials.db_username
  instance_class    = var.rds_instance_class
  engine_version    = var.rds_engine_version
  allocated_storage = var.rds_allocated_storage
  multi_az          = var.environment == "production"
}
