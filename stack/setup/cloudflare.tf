locals {
  distinct_domain_names = distinct(
    [for s in setunion([var.domain], aws_acm_certificate.main.subject_alternative_names) : replace(s, "*.", "")]
  )
  # https://github.com/hashicorp/terraform/issues/26043
  domain_validation_options = distinct(
    [for k, v in aws_acm_certificate.main.domain_validation_options : merge(
      tomap(v), { domain_name = replace(v.domain_name, "*.", "") }
    )]
  )
}

data "cloudflare_zone" "default" {
  name = var.domain
}

# domain validation
resource "cloudflare_record" "validation" {
  # We assume that a read-replica stack runs on the same domain, hence we skip Cloudflare
  count = var.is_read_replica_on_same_domain ? 0 : length(local.distinct_domain_names)

  zone_id = data.cloudflare_zone.default.id
  name    = element(local.domain_validation_options, count.index)["resource_record_name"]
  type    = element(local.domain_validation_options, count.index)["resource_record_type"]
  # ACM DNS validation record returns the value with a trailing dot however the Cloudflare API trims it off.
  # https://github.com/cloudflare/terraform-provider-cloudflare/issues/154
  value = trimsuffix(element(local.domain_validation_options, count.index)["resource_record_value"], ".")
}

resource "aws_acm_certificate_validation" "default" {
  count = var.is_read_replica_on_same_domain ? 0 : 1

  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = cloudflare_record.validation.*.hostname
}

# If you came across this error:
# Error: invalid zone setting "cname_flattening" (value: ) found - cannot be set as it is read only
# 1. terraform state rm module.<module-name>.cloudflare_zone_settings_override.tls
# 2. terraform apply
# https://github.com/cloudflare/terraform-provider-cloudflare/issues/808
resource "cloudflare_zone_settings_override" "tls" {
  zone_id = data.cloudflare_zone.default.id

  settings {
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    ssl                      = "strict"
  }
}
