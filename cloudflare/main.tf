data "cloudflare_zone" "default" {
  name = var.domain
}

# api.my-project.com to the NLB
resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.default.id
  name    = "api"
  type    = "CNAME"
  value   = var.alb_dns_name
  proxied = true
}

# bastion.my-project.com
resource "cloudflare_record" "bastion" {
  count = var.bastion_enabled ? 1 : 0

  zone_id = data.cloudflare_zone.default.id
  name    = "bastion"
  type    = "CNAME"
  value   = var.bastion_public_dns
  proxied = false
}

# cdn.my-project.com to the S3-Bucket -> e.g. folder "public"
# app.my-project.com to the S3-Bucket -> e.g. folder "app"
resource "cloudflare_record" "s3" {
  for_each = var.s3_cloudflare_records

  zone_id = data.cloudflare_zone.default.id
  name    = each.key
  type    = "CNAME"
  value   = var.domain
  proxied = true
}

resource "cloudflare_worker_route" "route" {
  for_each = var.s3_cloudflare_records

  zone_id     = data.cloudflare_zone.default.id
  pattern     = "*${data.key}.${var.domain}/*"
  script_name = data.value.worker_script_name
}
