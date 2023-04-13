module "s3-storage" {
  source = "../s3-private"

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = var.s3_bucket_name
}
