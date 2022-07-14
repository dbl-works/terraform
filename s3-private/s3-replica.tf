
module "kms-key-s3-replica" {
  for_each = var.replica_regions

  source = "../kms-key"

  # TODO: replica bucket name
  alias                   = "s3-${var.bucket_name}-replica-${each.key}"
  project                 = var.project
  environment             = var.environment
  description             = "Used for encrypting files in a private bucket replica"
  deletion_window_in_days = var.kms_deletion_window_in_days
}

module "s3-replica" {
  count = length(var.replica_regions)

  source = "../s3-replica"

  region             = var.replica_regions[count.index]
  source_bucket_name = var.bucket_name
  versioning         = var.versioning
  kms_key_arn        = module.kms-key-s3-replica[var.replica_regions[count.index]].arn

  depends_on = [
    aws_s3_bucket_versioning.main-bucket-versioning
  ]
}
