module "kms-key" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2021.07.09"

  # Required
  environment = local.environment
  project     = local.project
  alias       = "proxy"
  description = "Used for application secrets and related resources"
}
