module "cloudflare" {
  for_each = var.project_settings
  source   = "../../../cloudflare"

  depends_on = [
    module.ecs,
    module.s3-frontend,
  ]

  domain                = var.project_settings[each.key].domain
  alb_dns_name          = module.ecs.alb_dns_name
  s3_cloudflare_records = var.project_settings[each.key].s3_cloudflare_records

  # optional
  bastion_enabled    = false
  tls_settings       = var.tls_settings
  bastion_public_dns = module.ecs.nlb_dns_name
}
