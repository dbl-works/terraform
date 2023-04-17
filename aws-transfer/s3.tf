module "s3-storage" {
  count  = var.s3_bucket_name ? 1 : 0
  source = "../s3-private"

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = var.s3_bucket_name
}
