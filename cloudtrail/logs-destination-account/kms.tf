module "cloudtrail-kms" {
  source = "../kms-key"

  # Required
  environment = var.environment
  project     = var.organization_name
  alias       = "cloudtrail"
  description = "Used for cloudtrail encryption."
}
