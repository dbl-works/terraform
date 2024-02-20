module "s3-main" {
  source = "../s3-private"

  # Required
  environment = var.environment
  project     = var.github_org
  bucket_name = "${var.github_org}-${var.environment}-github-backup"

  # Optional
  policy_allow_listing_all_buckets = false # Do not allow listing this bucket to regular users
}
