# https://circleci.com/blog/azure-custom-images
module "container-registry" {
  source = "../container-registry"

  name                          = var.container_registry_config.name
  resource_group_name           = var.resource_group_name
  environment                   = var.environment
  region                        = var.region
  project                       = var.project
  # TODO: Verify whether this is the best practice and what is the potential risk
  admin_enabled                 = var.container_registry_config.admin_enabled
  sku                           = var.container_registry_config.sku
  user_assigned_identity_ids    = [azurerm_user_assigned_identity.main.id]
  retention_in_days             = var.container_registry_config.retention_in_days
  encryption_client_id          = azurerm_user_assigned_identity.main.client_id
  key_vault_key_id              = azurerm_key_vault_key.main.id
  public_network_access_enabled = var.container_registry_config.public_network_access_enabled
}

output "container-registry" {
  value = module.container-registry
}
