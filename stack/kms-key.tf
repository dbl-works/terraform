module "kms-key" {
  source = "github.com/dbl-works/terraform//kms-key?ref=${var.module_version}"

  # Required
  environment = var.environment
  project     = var.project
  alias       = var.kms_alias
  description = var.kms_description

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}
