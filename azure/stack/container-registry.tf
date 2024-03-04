module "container-registry" {
  source = "../container-registry"

  resource_group_name        = var.resource_group_name
  environment                = var.environment
  region                     = var.region
  project                    = var.project
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  encryption_client_id       = azurerm_user_assigned_identity.main.client_id
  retention_in_days          = var.retention_in_days
}
