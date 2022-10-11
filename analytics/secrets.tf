module "kms-key" {
  source = "../kms-key"

  # Required
  environment  = local.environment
  project      = local.project
  alias        = "analytics"
  description  = "Used for account credentials for resources related to analytics."
  multi_region = false
}

module "secrets" {
  source = "../secrets"

  project     = local.project
  environment = local.environment
  application = "snowflake-cloud"
  description = "Secrets required for managing Snowflake Cloud."
  kms_key_id  = module.kms-key.id
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = module.secrets.id
  secret_string = file("${path.cwd}/secrets.json")
}
