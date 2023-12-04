module "secrets" {
  source = "../secrets"

  project     = var.project
  environment = local.environment

  # Optional
  application = "circleci"
  description = "Secrets for rotating CircleCI token"
}
