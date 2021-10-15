resource "aws_s3_bucket" "main" {
  bucket = var.domain_name
  acl    = var.acl

  website {
    index_document = var.index_document
    error_document = var.single_page_application ? var.index_document : var.error_document
    routing_rules  = var.routing_rules
  }

  tags = {
    Name        = var.domain_name
    Project     = var.project
    Environment = var.environment
  }
}
