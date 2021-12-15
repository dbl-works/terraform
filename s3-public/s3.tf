resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "public-read"

  versioning {
    enabled = var.versioning
  }

  # Move data to a cheaper storage class after a period of time
  lifecycle_rule {
    enabled = var.primary_storage_class_retention == -1 ? false : false

    noncurrent_version_transition {
      days          = var.primary_storage_class_retention
      storage_class = "STANDARD_IA"
    }
  }

  tags = {
    Name        = var.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}
