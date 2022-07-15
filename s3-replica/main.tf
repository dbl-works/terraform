provider "aws" {
  alias = "replica"

  region = var.region
}

data "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
}

resource "aws_s3_bucket" "replica" {
  provider = aws.replica

  bucket = "${var.source_bucket_name}-replica-${var.region}"
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}
