module "s3" {
  source = "../s3"

  environment = var.environment
  project     = var.project
  bucket_name = local.bucket_name

  versioning           = true
  multi_region_kms_key = false
  enable_encryption    = false
}


resource "aws_s3_bucket_server_side_encryption_configuration" "main-bucket-sse-configuration" {
  bucket = module.s3.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = module.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_cors_configuration" "main-bucket-cors-configuration" {
  bucket = module.s3.bucket_name

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main-bucket-lifecycle-rule" {
  bucket = module.s3.id

  rule {
    id     = "primary-storage-class-retention"
    status = "Enabled"
    noncurrent_version_transition {
      noncurrent_days = 365
      storage_class   = "STANDARD_IA"
    }
  }
}
