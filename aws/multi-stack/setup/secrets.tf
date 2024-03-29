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


module "infra-secrets" {
  source = "../../secrets"

  create_kms_key = true

  project     = var.project
  environment = var.environment

  # Optional
  application = "infra"
  description = "Stores secrets for use for infrastructure"
}


resource "aws_secretsmanager_secret_version" "app" {
  for_each = var.project_settings

  secret_id     = module.secrets[each.key].id
  secret_string = file("${path.cwd}/app-secrets/${each.key}.json")
}

# We only need one infra secret manager for each multi-stack
resource "aws_secretsmanager_secret_version" "infra" {
  secret_id     = module.infra-secrets.id
  secret_string = file("${path.cwd}/infra-secrets.json")
}
