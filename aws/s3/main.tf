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

data "aws_iam_policy_document" "writers" {
  for_each = { for writer in var.writers : writer.policy_id => writer }

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.main.arn}/${each.value.prefix}/*"]
    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type = "AWS"
    }
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.main.arn}/${each.value.prefix}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type = "Service"
    }
  }
  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect = "Allow"
    resources = [aws_s3_bucket.main.arn]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_s3_bucket_policy" "writers" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": flatten([
      for policy in data.aws_iam_policy_document.writers : policy.statement
    ])
  })
}
