module "secrets" {
  source = "../../secrets"

  for_each       = var.project_settings
  create_kms_key = true
  kms_key_id     = module.secrets-kms-key[each.key].id

  project     = each.key
  environment = var.environment

  # Optional
  application = "app"
  description = "For applications to use inside containers"

  depends_on = [
    module.secrets-kms-key
  ]
}

resource "aws_secretsmanager_secret_version" "app" {
  for_each = var.project_settings

  secret_id     = module.secrets[each.key].id
  secret_string = file("${path.cwd}/app-secrets/${each.key}.json")
}

module "secrets-kms-key" {
  source = "../../kms-key"

  for_each = var.project_settings

  # Required
  environment = var.environment
  project     = each.key
  alias       = each.key
  description = "kms key for ${each.key} app secrets"

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}
