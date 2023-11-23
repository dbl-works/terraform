module "service" {
  source = "../service"

  for_each = var.services

  app_config  = each.app_config
  environment = var.environment
  project     = var.project
}
