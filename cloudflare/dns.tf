# api.my-project.com to the NLB
resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.default.id
  name    = "api"
  type    = "CNAME"
  content = var.alb_dns_name
  proxied = true
}

# bastion.my-project.com
resource "cloudflare_record" "bastion" {
  count = var.bastion_enabled ? 1 : 0

  zone_id = data.cloudflare_zone.default.id
  name    = "bastion"
  type    = "CNAME"
  content = var.bastion_public_dns
  proxied = false
}

# cdn.my-project.com to the S3-Bucket -> e.g. folder "public"
# app.my-project.com to the S3-Bucket -> e.g. folder "app"
resource "cloudflare_record" "s3" {
  for_each = var.s3_cloudflare_records

  zone_id = data.cloudflare_zone.default.id
  name    = each.key
  type    = "CNAME"
  content = var.domain
  proxied = true
}

# DNSSEC outputs a public key that must be added to AWS Route53
# Under "Domains" -> "Registered Domains" -> "DNSSEC status"
resource "cloudflare_zone_dnssec" "main" {
  zone_id = data.cloudflare_zone.default.id
}
