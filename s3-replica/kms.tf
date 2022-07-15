module "kms_key" {
  count  = var.enable_encryption ? 1 : 0
  source = "../kms-key"

  alias                   = "s3-${local.replica_bucket_name}"
  project                 = var.project
  environment             = var.environment
  description             = "Used for encrypting files in a private bucket replica"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
