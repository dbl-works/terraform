data "azurerm_key_vault_secret" "database_user" {
  name         = "database-user"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "database_password" {
  name         = "database-password"
  key_vault_id = var.key_vault_id
}

module "database" {
  source = "../../database/postgres"

  db_name             = var.database_config.name
  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment
  private_dns_zone_id = module.virtual-network.db_private_dns_zone_id
  delegated_subnet_id = module.virtual-network.db_subnet_id

  public_network_access_enabled = var.database_config.public_network_access_enabled

  # Key vault must be created before database
  administrator_login    = data.azurerm_key_vault_secret.database_user.value
  administrator_password = data.azurerm_key_vault_secret.database_password.value

  # Optional
  user_assigned_identity_ids = [data.azurerm_user_assigned_identity.main.id]
  postgres_version           = var.database_config.version
  storage_mb                 = var.database_config.storage_mb
  storage_tier               = var.database_config.storage_tier
  sku_name                   = var.database_config.sku_name
  tags                       = var.tags
}
