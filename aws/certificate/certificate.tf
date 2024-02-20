# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate

resource "aws_acm_certificate" "main" {
  domain_name = var.domain_name

  subject_alternative_names = flatten(concat(
    var.add_wildcard_subdomains ? ["*.${var.domain_name}"] : [],
    var.alternative_domains,
  ))

  validation_method = "DNS"

  tags = {
    Name        = var.domain_name
    Project     = var.project
    Environment = var.environment
  }

  # When attached to a load balancer it cannot be destroyed.
  # This means we need to create a new one, attach it, then destroy the original.
  lifecycle {
    create_before_destroy = true
  }
}
