# TODO: Create a Service Principal ID which can do the following:
# - Access Container Registry
# - Access Container App

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = var.resource_group_name
  location            = var.region

  name = var.user_assigned_identity_name

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
