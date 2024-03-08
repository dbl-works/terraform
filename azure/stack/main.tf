resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = var.resource_group_name
  location            = var.region

  name = local.name

  tags = var.default_tags
}

# A Container Apps environment is a secure boundary around groups of container apps that share the same virtual network and write logs to the same logging destination.
resource "azurerm_container_app_environment" "main" {
  name                       = local.name
  location                   = var.region
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = module.observability.id

  tags = var.default_tags
}

### Output
output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.main.id
}

output "user_assigned_identity_tenant_id" {
  value = azurerm_user_assigned_identity.main.tenant_id
}

output "user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.main.principal_id
}
