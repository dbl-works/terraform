
module "rds" {
  source = "github.com/dbl-works/terraform//rds?ref=${var.module_version}"

  account_id = "12345678"
  region     = "eu-central-1"
  vpc_id     = "vpc-123"
  project    = "someproject"
  # TODO: Passing this as variables?
  environment                = "staging"
  password                   = "xxx"
  kms_key_arn                = "arn:aws:kms:eu-central-1:12345678:key/xxx-xxx"
  subnet_ids                 = ["subnet-1", "subnet-2"]
  allow_from_security_groups = [module.ecs.ecs_security_group_id]

  # optional
  # TODO: Larger for production
  instance_class = "db.t3.micro"
  # TODO: Check on the list of existing engine version
  engine_version = "13.2"
  # TODO: Do we need so much for staging?
  allocated_storage = 100
  # TODO: true for production?
  multi_az = false
}
