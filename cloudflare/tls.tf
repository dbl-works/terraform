# If you came across this error:
# Error: invalid zone setting "cname_flattening" (value: ) found - cannot be set as it is read only
# 1. terraform state rm module.<module-name>.cloudflare_zone_settings_override.tls
# 2. terraform apply
# https://github.com/cloudflare/terraform-provider-cloudflare/issues/808
resource "cloudflare_zone_settings_override" "tls" {
  count   = var.https_enabled ? 1 : 0
  zone_id = data.cloudflare_zone.default.id

  settings {
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    ssl                      = "strict"
    always_use_https         = "on"
  }
}
