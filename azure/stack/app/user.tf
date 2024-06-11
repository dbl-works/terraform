resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = var.resource_group_name
  location            = var.region

  name = var.user_assigned_identity_name

  tags = var.tags
}

