locals {
  distinct_domain_names = var.is_read_replica_on_same_domain ? [] : distinct(
    [for s in setunion([var.domain], aws_acm_certificate.main[0].subject_alternative_names) : replace(s, "*.", "")]
  )
  # https://github.com/hashicorp/terraform/issues/26043
  domain_validation_options = var.is_read_replica_on_same_domain ? [] : distinct(
    [for k, v in aws_acm_certificate.main[0].domain_validation_options : merge(
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

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = cloudflare_record.validation.*.hostname
}

resource "cloudflare_ruleset" "clickjacking" {
  account_id  = "f037e56e89293a057740de681ac9abbe"
  name        = "clickjacking"
  description = "example magic transit ruleset description"
  kind        = "root"
  phase       = "magic_transit"

  rules {
    action      = "allow"
    expression  = "tcp.dstport in { 32768..65535 }"
    description = "Allow TCP Ephemeral Ports"
  }
}

resource "cloudflare_ruleset" "clickjacking" {
  zone_id     = data.cloudflare_zone.default.id
  name        = "Clickjacking"
  description = "Prevent clickjacking"
  kind        = "zone"
  phase       = "http_response_headers_transform"

  rules {
    action = "rewrite"
    action_parameters {
      headers {
        name      = "X-Frame-Options"
        operation = "set"
        value     = "SAMEORIGIN"
      }
    }
    expression  = "true"
    description = "Clickjacking"
    enabled     = true
  }
}
