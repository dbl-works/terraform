resource "cloudflare_zone" "default" {
  zone = var.domain
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
  count = var.bastion_public_dns == null ? 0 : 1

  zone_id = cloudflare_zone.default.id
  name    = "bastion"
  type    = "CNAME"
  value   = var.bastion_public_dns
  proxied = false
}

# cdn.my-project.com to the S3-Bucket (using Cloudflare Workers)
# xx.my-project.com to the S3-Bucket (using Cloudflare Workers) for any subdomain needed
resource "cloudflare_record" "s3" {
  for_each = { for bucket in var.s3_public_buckets : bucket.name => bucket }

  zone_id = cloudflare_zone.default.id
  name    = each.key
  type    = "CNAME"
  value   = var.domain
  proxied = true
}

resource "cloudflare_worker_route" "cdn_route" {
  for_each = { for bucket in var.s3_public_buckets : bucket.name => bucket }

  zone_id     = cloudflare_zone.default.id
  pattern     = "*${each.value.cdn_path}.${var.domain}/*"
  script_name = var.cdn_worker_script_name
}
