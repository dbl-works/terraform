locals {
  # https://github.com/hashicorp/terraform/issues/26043
  domain_validation_options = { for project_name, _ in var.project_settings :
    project_name => distinct(
      [for k, v in aws_acm_certificate.main[project_name].domain_validation_options : merge(
        tomap(v), { domain_name = replace(v.domain_name, "*.", "") }
    )])
  }
}

data "cloudflare_zone" "default" {
  for_each = var.project_settings

  name = each.value.domain
}

# domain validation
resource "cloudflare_record" "validation" {
  # We assume that a read-replica stack runs on the same domain, hence we skip Cloudflare
  for_each = var.project_settings

  zone_id = data.cloudflare_zone.default[each.key].id
  name    = local.domain_validation_options[each.key][0]["resource_record_name"]
  type    = local.domain_validation_options[each.key][0]["resource_record_type"]
  # ACM DNS validation record returns the value with a trailing dot however the Cloudflare API trims it off.
  # https://github.com/cloudflare/terraform-provider-cloudflare/issues/154
  value = trimsuffix(local.domain_validation_options[each.key][0]["resource_record_value"], ".")
}

resource "aws_acm_certificate_validation" "default" {
  for_each = var.project_settings

  certificate_arn = aws_acm_certificate.main[each.key].arn
  # attribute "validation_record_fqdns": set of string required.
  validation_record_fqdns = [cloudflare_record.validation[each.key].hostname]
}
