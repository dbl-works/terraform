module "kms-key" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2021.07.13"

  # Required
  environment = var.environment
  project     = var.project
  alias       = "proxy"
  description = "Used for application secrets and related resources"
}
