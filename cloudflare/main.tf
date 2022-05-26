provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

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
  name    = aws_acm_certificate.default.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.default.domain_validation_options.0.resource_record_type
  # ACM DNS validation record returns the value with a trailing dot however the Cloudflare API trims it off.
  # https://github.com/cloudflare/terraform-provider-cloudflare/issues/154
  value = trimsuffix(aws_acm_certificate.default.domain_validation_options.0.resource_record_value, ".")
}

# domain validation
resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn

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

data "aws_eip" "bastion" {
  id = var.bastion_eip_id
}

# bastion.my-project.com
resource "cloudflare_record" "bastion" {
  zone_id = cloudflare_zone.default.id
  name    = "bastion"
  type    = "CNAME"
  value   = aws_eip.bastion.public_dns
  proxied = false
}

# Runs the specified worker script for all URLs that match `example.com/*`
# Any calls to this are cached in Cloudflare’s network cache,
# https://cdn.${domain}/<file-name>?attach=attachment
resource "cloudflare_worker_route" "cdn_route" {
  zone_id     = cloudflare_zone.default.id
  pattern     = var.s3_bucket_cdn_subdomain ? concat(["*cdn.${var.domain}/*"], ["*${var.s3_bucket_cdn_subdomain}.${var.domain}/*"]) : ["*cdn.${var.domain}/*"]
  script_name = var.worker_script_name
}

# BIG IMPORTANT NOTE: DO NOT PUT PERIODS IN YOUR BUCKET NAME. staging-project is valid,
# but staging.project will cause every fetch to have a TLS handshake error: invalid certificate.
# The Amazon S3 TLS certificate for, let’s say, the us-east-2 region, is *.s3.us-east-2.amazonaws.com.
# That wildcard does not count for multiple subdomain levels, meaning that the TLS certificate for your bucket will not match the name of your bucket.
# This is why CloudFront won’t take buckets with dots in their name.
resource "cloudflare_record" "cdn" {
  zone_id = cloudflare_zone.default.id
  name    = "cdn"
  type    = "CNAME"
  value   = var.domain
  proxied = true
}

# S3
# xx.my-project.com to the S3-Bucket (using Cloudflare Workers) for any subdomain needed
resource "cloudflare_record" "s3" {
  count   = var.s3_bucket_cdn_subdomain ? 1 : 0
  zone_id = cloudflare_zone.default.id
  name    = var.s3_bucket_cdn_subdomain
  type    = "CNAME"
  value   = var.domain
  proxied = true
}

