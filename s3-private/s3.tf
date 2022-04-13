resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main-bucket-lifecycle-rule" {
  bucket = aws_s3_bucket.main.id

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
  bucket = aws_s3_bucket.main.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }
}

resource "aws_s3_bucket_versioning" "main-bucket-versioning" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_acl" "main-bucket-data-acl" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main-bucket-sse-configuration" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms-key-s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block-all-access" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
