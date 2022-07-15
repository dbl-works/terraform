locals {
  replica_bucket_name = "${var.source_bucket_name}-replica-${var.region}"
}

resource "aws_s3_bucket" "replica" {
  bucket = local.replica_bucket_name

  tags = {
    Name        = local.replica_bucket_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  bucket = aws_s3_bucket.replica.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}
