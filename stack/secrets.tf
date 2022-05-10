# TODO: Secrets Manager create one vault for backend app, and one for terraform root credentials
# All required credentials for running the rails backend should be automatically populated (e.g. Postgres url, redis url, etc)
module "secrets" {
  source = "github.com/dbl-works/terraform//secrets?ref=${var.module_version}"

  project     = var.project
  environment = var.environment

  # Optional
  application = "app"
}
