resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

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

data "aws_elb_service_account" "main" {}

locals {
  writers_policy_json = jsonencode({
    "Version": "2012-10-17",
    "Statement": flatten([
      for writer in var.writers : [
        {
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Resource": "${aws_s3_bucket.main.arn}/${writer.prefix}/*",
          "Principal": {
            "AWS": "${data.aws_elb_service_account.main.arn}"
          }
        },
        {
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Resource": "${aws_s3_bucket.main.arn}/${writer.prefix}/*",
          "Principal": {
            "Service": "delivery.logs.amazonaws.com"
          }
        },
        {
          "Effect": "Allow",
          "Action": "s3:GetBucketAcl",
          "Resource": "${aws_s3_bucket.main.arn}",
          "Principal": {
            "Service": "delivery.logs.amazonaws.com"
          }
        }
      ]
    ])
  })
}

resource "aws_s3_bucket_policy" "writers" {
  bucket = aws_s3_bucket.main.id
  policy = local.writers_policy_json
}
