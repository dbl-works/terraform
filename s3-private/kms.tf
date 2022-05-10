module "kms-key-s3" {
  source = "../kms-key"

  alias                   = "s3-${var.bucket_name}"
  project                 = var.project
  environment             = var.environment
  description             = "Used for encrypting files in a private bucket"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
