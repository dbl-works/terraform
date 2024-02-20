module "s3-storage" {
  count  = var.s3_bucket_name == null ? 0 : 1
  source = "../s3-private"

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = var.s3_bucket_name
}
