resource "aws_s3_bucket" "main" {
  bucket = "cdn.${var.domain_name}"
  acl    = "public-read"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 120
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }

  tags = {
    Name        = "cdn.${var.domain_name}"
    Project     = var.project
    Environment = var.environment
  }
}
