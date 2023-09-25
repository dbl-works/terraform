module "secrets" {
  source = "../secrets"

  project     = var.github_org
  environment = var.environment

  # Optional
  application = "github-backup"
  description = "Secrets required to backup Github Repositories for ${var.github_org}."
}
