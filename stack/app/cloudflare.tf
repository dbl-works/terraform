module "cloudflare" {
  source = "../../cloudflare"

  depends_on = [
    module.ecs,
    module.s3-frontend,
  ]

  domain                 = var.domain_name
  alb_dns_name           = module.ecs.alb_dns_name
  cdn_worker_script_name = "serve-cdn"
  app_worker_script_name = "serve-app"

  # optional
  # bastion_public_dns = module.ecs.nlb_target_group_ecs_arn
}
