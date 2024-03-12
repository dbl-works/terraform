module "observability" {
  source = "../observability/monitors"

  resource_group_name = var.resource_group_name
  environment         = var.environment
  region              = var.region
  project             = var.project

  log_analytics_workspace_id = module.container-app.log_analytics_workspace_id
  logs_retention_in_days     = var.container_app_config.logs_retention_in_days
  container_app_id           = module.container-app.id
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
}
