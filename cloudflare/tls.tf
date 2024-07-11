# If you came across this error:
# Error: invalid zone setting "cname_flattening" (value: ) found - cannot be set as it is read only
# 1. terraform state rm module.<module-name>.cloudflare_zone_settings_override.tls
# 2. terraform apply
# https://github.com/cloudflare/terraform-provider-cloudflare/issues/808
resource "cloudflare_zone_settings_override" "tls" {
  count   = var.tls_settings == null ? 0 : 1
  zone_id = data.cloudflare_zone.default.id

  settings {
    tls_1_3                  = var.tls_settings.tls_1_3
    min_tls_version          = var.tls_settings.min_tls_version
    automatic_https_rewrites = var.tls_settings.automatic_https_rewrites
    ssl                      = var.tls_settings.ssl
    always_use_https         = var.tls_settings.always_use_https

    security_header {
      enabled            = var.hsts_settings.enabled
      include_subdomains = var.hsts_settings.include_subdomains
      max_age            = var.hsts_settings.max_age
      nosniff            = var.hsts_settings.nosniff
      preload            = var.hsts_settings.preload
    }
  }
}
