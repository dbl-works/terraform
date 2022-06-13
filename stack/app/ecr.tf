module "ecr" {
  source = "../../ecr"

  project = var.project

  # Optional
  mutable = var.mutable_ecr
}
