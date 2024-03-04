module "observability" {
  source = "../observability"

  resource_group_name = var.resource_group_name
  environment         = var.environment
  region              = var.region
  project             = var.project

  target_resource_id         = module.container-app.id
  logs_retention_in_days     = var.observability_config.logs_retention_in_days
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
}
