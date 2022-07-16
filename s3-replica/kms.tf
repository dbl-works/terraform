# Amazon S3 currently treats multi-Region keys as though
# they were single-Region keys, and does not use the multi-Region features
# Therefore, if the replica also need to be encrypted, a kms key in the destination bucket region needs to be provided
module "kms_key" {
  count  = var.enable_encryption ? 1 : 0
  source = "../kms-key"

  alias                   = "s3-${local.replica_bucket_name}"
  project                 = var.project
  environment             = var.environment
  description             = "Used for encrypting files in a private bucket replica"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
