module "secrets" {
  source = "../../secrets"

  for_each       = var.project_settings
  create_kms_key = true

  project     = each.key
  environment = var.environment

  # Optional
  application = "app"
  description = "For applications to use inside containers"
}

resource "aws_secretsmanager_secret_version" "app" {
  for_each = var.project_settings

  secret_id     = module.secrets[each.key].id
  secret_string = file("${path.cwd}/app-secrets/${each.key}.json")
}
