resource "aws_s3_bucket" "main" {
  bucket              = var.bucket_name
  acl                 = "private"
  block_public_acls   = true
  block_public_policy = true

  versioning {
    enabled = var.versioning
  }

  lifecycle_rule {
    enabled = var.primary_storage_class_retention == 0 ? false : false

    noncurrent_version_transition {
      days          = var.primary_storage_class_retention == 0 ? 365 : var.primary_storage_class_retention
      storage_class = "STANDARD_IA"
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.kms-key-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }

  tags = {
    Name        = var.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}
