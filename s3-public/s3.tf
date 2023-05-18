module "s3" {
  source = "../s3"

  environment       = var.environment
  project           = var.project
  bucket_name       = var.bucket_name
  versioning        = var.versioning
  enable_encryption = false
}

resource "aws_s3_bucket_acl" "main-bucket-data-acl" {
  bucket = module.s3.id
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_public_access_block.main
  ]
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = module.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = module.s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Move data to a cheaper storage class after a period of time
resource "aws_s3_bucket_lifecycle_configuration" "main-bucket-lifecycle-rule" {
  bucket = module.s3.id

  rule {
    id     = "primary-storage-class-retention"
    status = var.primary_storage_class_retention == 0 ? "Disabled" : "Enabled"
    noncurrent_version_transition {
      noncurrent_days = var.primary_storage_class_retention == 0 ? 365 : var.primary_storage_class_retention
      storage_class   = "STANDARD_IA"
    }
  }
}
