module "kms-key-s3" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2021.11.13"

  alias                   = var.bucket_name
  project                 = var.project
  environment             = var.environment
  description             = "Used for encrypting files in the storage bucket"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
