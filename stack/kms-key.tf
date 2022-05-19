module "kms-key" {
  source = "../kms-key"

  for_each = { for kms in var.kms_list : kms.alias => kms }

  # Required
  environment = var.environment
  project     = var.project
  alias       = each.value.alias
  description = each.value.description

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}
