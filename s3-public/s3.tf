resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "public-read"

  versioning {
    enabled = var.versioning
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 120
      storage_class = "STANDARD_IA"
    }
  }

  tags = {
    Name        = var.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}
