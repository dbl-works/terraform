module "service" {
  source = "../service"

  for_each = var.services

  environment = var.environment
  project     = var.project
  region      = var.region
  regional    = var.regional

  app_config     = each.value.app_config
  sidecar_config = each.value.sidecar_config

  cpu                             = each.value.cpu
  memory                          = each.value.memory
  desired_count                   = each.value.desired_count
  with_load_balancer              = each.value.with_load_balancer
  ephemeral_storage_size_in_gib   = each.value.ephemeral_storage_size_in_gib
  load_balancer_target_group_name = each.value.load_balancer_target_group_name
}
