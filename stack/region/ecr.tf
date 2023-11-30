module "ecr" {
  source = "../../ecr"

  project = var.project

  # Optional
  mutable = var.mutable_ecr
  valid_days = var.valid_days
  ecr_lifecycle_policy_rules = var.ecr_lifecycle_policy_rules
}
