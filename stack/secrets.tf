locals {
  secret_vaults = {
    app = {
      description = "For applications to use inside containers"
    },
    terraform = {
      description = "Stores secrets for use in terraform workspace"
    }
  }

  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.terraform.secret_string
  )

  app_secrets = {
    "database_url": module.rds.database_url,
    "redis_url": module.elasticache.endpoint
  }
}

module "secrets" {
  source = "../secrets"

  for_each = local.secret_vaults
  kms_key_id = module.secrets-kms-key[each.key].id

  project     = var.project
  environment = var.environment

  # Optional
  application = each.key
  description = each.value.description
}


resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = module.secrets["app"].id
  secret_string = jsonencode(merge(jsondecode(file("${path.cwd}/app-secrets.json")), local.app_secrets))
}

resource "aws_secretsmanager_secret_version" "terraform" {
  secret_id = module.secrets["terraform"].id
  secret_string = file("${path.cwd}/terraform-secrets.json")
}

# NOTE: Running this at the first time will throw Version "AWSCURRENT" not found because
# aws_secretsmanager_secret_version is not created yet that time
# The dependency should be resolve by terraform however it doesn't work here
data "aws_secretsmanager_secret_version" "terraform" {
  secret_id = module.secrets["terraform"].id
}

module "secrets-kms-key" {
  source = "../kms-key"

  for_each = local.secret_vaults

  # Required
  environment = var.environment
  project     = var.project
  alias       = each.key
  description = "kms key for ${var.project} ${each.key} secrets"

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}
