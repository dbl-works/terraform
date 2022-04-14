module "kms-key-s3" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2022.04.13"

  alias                   = "s3-${var.bucket_name}"
  project                 = var.project
  environment             = var.environment
  description             = "Used for encrypting files in a private bucket"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
