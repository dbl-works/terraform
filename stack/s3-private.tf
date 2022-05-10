module "s3-storage" {
  source = "github.com/dbl-works/terraform//s3-private?ref=${var.module_version}"

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = "${var.project}-${var.environment}-storage"

  # Optional
  kms_deletion_window_in_days     = 30
  versioning                      = true
  primary_storage_class_retention = 0
}
