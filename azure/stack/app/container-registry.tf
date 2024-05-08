# https://circleci.com/blog/azure-custom-images
module "container-registry" {
  source = "../../container-registry"

  name                = var.container_registry_config.name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  region              = var.region
  project             = var.project

  admin_enabled                 = var.container_registry_config.admin_enabled
  sku                           = var.container_registry_config.sku
  retention_in_days             = var.container_registry_config.retention_in_days
  key_vault_key_id              = var.key_vault_key_id
  public_network_access_enabled = var.container_registry_config.public_network_access_enabled
  private_endpoint_config = {
    virtual_network_id = module.virtual-network.id
    subnet_id          = module.virtual-network.private_subnet_id
  }
  user_assigned_identity_name = azurerm_user_assigned_identity.main.name
  encryption_client_id        = azurerm_user_assigned_identity.main.client_id

  tags = var.tags
}

output "container-registry" {
  value = module.container-registry
}
