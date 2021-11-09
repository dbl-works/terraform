module "kms-key-app" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2021.11.09"

  alias = "app"
  project = var.project
  environment = var.environment
  description = "Used for application secrets"
}

module "kms-key-rds" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2021.11.09"

  alias = "rds"
  project = var.project
  environment = var.environment
  description = "Used for encrypting database and backups"
}
