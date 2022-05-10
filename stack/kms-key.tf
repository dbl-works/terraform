module "kms-key" {
  source = "github.com/dbl-works/terraform//kms-key?ref=${var.module_version}"

  # Required
  environment = var.environment
  project     = var.project
  alias       = "rds"
  description = "Used for ecrypting databases and their backups"

  # Optional
  deletion_window_in_days = 30
}
