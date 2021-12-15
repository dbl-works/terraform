resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
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
  }

  tags = {
    Name        = local.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}
