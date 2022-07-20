module "s3" {
  source = "../s3"

  environment                 = var.environment
  project                     = var.project
  bucket_name                 = var.bucket_name
  versioning                  = var.versioning
  kms_deletion_window_in_days = var.kms_deletion_window_in_days
  enable_encryption           = true
}

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

resource "aws_s3_bucket_cors_configuration" "main-bucket-cors-configuration" {
  bucket = module.s3.bucket_name

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }
}

resource "aws_s3_bucket_acl" "main-bucket-data-acl" {
  bucket = module.s3.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main-bucket-sse-configuration" {
  bucket = module.s3.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.s3.kms_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block-all-access" {
  bucket = module.s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
