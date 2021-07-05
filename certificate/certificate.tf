resource "aws_acm_certificate" "main" {
  domain_name = var.domain_name

  subject_alternative_names = var.add_wildcard_subdomains ? ["*.${var.domain_name}"] : []

  validation_method = "DNS"

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}
