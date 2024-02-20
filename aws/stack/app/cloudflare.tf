module "cloudflare" {
  source = "../../cloudflare"
  count  = var.skip_cloudflare ? 0 : 1

  depends_on = [
    module.ecs,
    module.s3-frontend,
  ]

  domain                = var.domain_name
  alb_dns_name          = module.ecs.alb_dns_name
  s3_cloudflare_records = var.s3_cloudflare_records

  # optional
  bastion_enabled    = true
  tls_settings       = var.tls_settings
  bastion_public_dns = module.ecs.nlb_dns_name
}
