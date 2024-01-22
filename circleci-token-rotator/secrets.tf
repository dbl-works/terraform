module "secrets" {
  source = "../secrets"

  project     = var.project
  environment = local.environment

  # Optional
  application = "circleci" # @NOTE: should we instead rename the "terraform" vault into "infra" and use that? that will reduce the number of vaults we ever need to 2: 1 for the app, 1 for all other infra stuff
  description = "Secrets for rotating CircleCI token"
}
