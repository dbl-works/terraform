module "secrets" {
  source = "../secrets"

  project     = var.project
  environment = var.environment

  # Optional
  application = "github-backup"
  description = "Secrets required to backup Github Repositories."
}
