module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare?ref=v2022.05.26"
  depends_on = [
    module.ecs,
    module.s3-frontend,
  ]

  domain                 = var.domain_name
  nlb_dns_name           = module.ecs.alb_target_group_ecs_arn
  cdn_worker_script_name = "serve-cdn"
  app_worker_script_name = "serve-app"
  public_bucket_name     = module.s3-frontend[0].bucket_name

  # optional
  bastion_public_dns = module.ecs.nlb_target_group_ecs_arn
}
