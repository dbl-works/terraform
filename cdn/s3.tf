resource "aws_s3_bucket" "main" {
  bucket = var.domain_name
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name        = var.domain_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "page_root",
        Action    = ["s3:ListBucket"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${var.domain_name}",
        Principal = { "AWS" : "${aws_cloudfront_origin_access_identity.main.iam_arn}" }
      },
      {
        Sid       = "page_all",
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${var.domain_name}/*",
        Principal = { "AWS" : "${aws_cloudfront_origin_access_identity.main.iam_arn}" }
      }
    ]
  })
}
