resource "aws_acm_certificate" "main" {
  for_each = var.project_settings

  domain_name = each.value.domain

  subject_alternative_names = flatten(concat(
    var.add_wildcard_subdomains ? ["*.${each.value.domain}"] : [],
    var.alternative_domains,
  ))

  validation_method = "DNS"

  tags = {
    Name        = each.value.domain
    Project     = each.key
    Environment = var.environment
  }

  # When attached to a load balancer it cannot be destroyed.
  # This means we need to create a new one, attach it, then destroy the original.
  lifecycle {
    create_before_destroy = true
  }
}
