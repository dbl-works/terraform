module "cloudflare" {
  source = "../../cloudflare"
  count  = var.skip_cloudflare ? 0 : 1

  depends_on = [
    module.ecs,
    module.s3-frontend,
  ]

  domain                 = var.domain_name
  alb_dns_name           = module.ecs.alb_dns_name
  cdn_worker_script_name = "serve-cdn"
  app_worker_script_name = "serve-app"

  # optional
  bastion_enabled    = true
  bastion_public_dns = module.ecs.nlb_dns_name
}
