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
