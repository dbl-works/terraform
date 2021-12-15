resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 120
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

  tags = {
    Name        = local.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}
