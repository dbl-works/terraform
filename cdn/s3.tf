resource "aws_s3_bucket" "main" {
  bucket = "cdn.${domain_name}"
  acl    = "public-read"

  website {
    index_document = "index.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = concat(["https://*.${var.domain_name}", "https://${var.domain_name}"], var.additional_allowed_origins)
    expose_headers  = []
    max_age_seconds = 3000
  }

  tags = {
    Name    = "cdn.${domain_name}"
    Project = var.project
  }
}
