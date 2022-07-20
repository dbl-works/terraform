resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}
