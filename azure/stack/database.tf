module "database" {
  source = "../database/postgres"

  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment
  private_dns_zone_id = module.virtual-network.db_private_dns_zone_id
  delegated_subnet_id = module.virtual-network.db_subnet_id

  # TODO: Pass this value using key vault
  # Key vault must be created before database
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  # Optional
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  postgres_version           = var.database_config.version
  storage_mb                 = var.database_config.storage_mb
  storage_tier               = var.database_config.storage_tier
  sku_name                   = var.database_config.sku_name
}
