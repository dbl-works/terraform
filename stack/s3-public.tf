module "s3-frontend" {
  source = "github.com/dbl-works/terraform//s3-public?ref=${var.module_version}"

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = "${var.project}-${var.environment}-frontend"

  # Optional
  versioning                      = false
  primary_storage_class_retention = 0
}
