module "observability" {
  source = "../../observability/monitors"

  log_analytics_workspace_name = var.observability_config.log_analytics_workspace_name
  blob_storage_name            = var.observability_config.blob_storage_name
  resource_group_name          = var.resource_group_name
  environment                  = var.environment
  region                       = var.region
  project                      = var.project

  logs_retention_in_days = var.container_app_config.logs_retention_in_days
  target_resource_ids_for_logging = [
    module.key-vault.id, # To enable resource logs in key vault
    # module.container-app.container_app_environment_id,
  ]
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]

  public_network_access_enabled = var.observability_config.public_network_access_enabled
  allowed_ips                   = var.allowed_ips

  tags = var.tags
}


output "observability" {
  value = module.observability
}
