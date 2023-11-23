module "global-accelerator" {
  count  = var.global_accelerator_config == null ? 0 : 1
  source = "../../global-accelerator"

  project     = var.project
  environment = var.environment

  health_check_path = var.global_accelerator_config.health_check_path
  health_check_port = var.global_accelerator_config.health_check_port
  client_affinity   = var.global_accelerator_config.client_affinity

  load_balancers = var.global_accelerator_config.load_balancers
}
