module "ecr" {
  source = "github.com/dbl-works/terraform//ecr?ref=${var.module_version}"

  project = var.project

  # Optional
  mutable = var.mutable_ecr
}
