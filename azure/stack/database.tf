module "database" {
  source = "../database/postgres"

  name                 = local.name
  virtual_network_name = local.name
  resource_group_name  = var.resource_group_name
  region               = var.region
  project              = var.project
  environment          = var.environment

  administrator_login    = var.administrator_login # TODO: Pass this value using key vault
  administrator_password = var.administrator_password

  # Optional
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  encryption_client_id       = azurerm_user_assigned_identity.main.client_id
  retention_in_days          = var.database_config.retention_in_days
  db_subnet_address_prefixes = var.database_config.db_subnet_address_prefixes
}
