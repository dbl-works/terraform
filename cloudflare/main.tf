locals {
  distinct_domain_names = distinct(
    [for s in concat([var.domain], var.subject_alternative_names) : replace(s, "*.", "")]
  )
}

resource "cloudflare_zone" "default" {
  zone = var.domain
}

data "aws_acm_certificate" "default" {
  domain = var.domain
}

# domain validation
resource "cloudflare_record" "validation" {
  count = length(local.distinct_domain_names)

  zone_id = cloudflare_zone.default.id
  name    = data.aws_acm_certificate.default.domain_validation_options.0.resource_record_name
  type    = data.aws_acm_certificate.default.domain_validation_options.0.resource_record_type
  # ACM DNS validation record returns the value with a trailing dot however the Cloudflare API trims it off.
  # https://github.com/cloudflare/terraform-provider-cloudflare/issues/154
  value = trimsuffix(data.aws_acm_certificate.default.domain_validation_options.0.resource_record_value, ".")
}

# domain validation
resource "aws_acm_certificate_validation" "default" {
  certificate_arn = data.aws_acm_certificate.default.arn

  validation_record_fqdns = cloudflare_record.validation.*.hostname
}

# api.my-project.com to the NLB
resource "cloudflare_record" "api" {
  zone_id = cloudflare_zone.default.id
  name    = "api"
  type    = "CNAME"
  value   = var.nlb_dns_name
  proxied = true
}

# bastion.my-project.com
resource "cloudflare_record" "bastion" {
  zone_id = cloudflare_zone.default.id
  name    = "bastion"
  type    = "CNAME"
  value   = var.bastion_public_dns
  proxied = false
}

# cdn.my-project.com to the S3-Bucket (using Cloudflare Workers)
# xx.my-project.com to the S3-Bucket (using Cloudflare Workers) for any subdomain needed
resource "cloudflare_record" "s3" {
  for_each = { for bucket in var.s3_cdn_buckets : bucket.name => bucket }

  zone_id = cloudflare_zone.default.id
  name    = each.key
  type    = "CNAME"
  value   = var.domain
  proxied = true
}

resource "cloudflare_worker_route" "cdn_route" {
  for_each = { for bucket in var.s3_cdn_buckets : bucket.name => bucket }

  zone_id     = cloudflare_zone.default.id
  pattern     = "*${each.value.cdn_path}.${var.domain}/*"
  script_name = var.cdn_worker_script_name
}
