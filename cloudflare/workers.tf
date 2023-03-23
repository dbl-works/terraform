resource "cloudflare_worker_route" "route" {
  for_each = var.s3_cloudflare_records

  zone_id     = data.cloudflare_zone.default.id
  pattern     = "*${each.key}.${var.domain}/*"
  script_name = each.value.worker_script_name
}
