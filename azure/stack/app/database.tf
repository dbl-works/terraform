module "database" {
  source = "../../database/postgres"

  db_name             = var.database_config.name
  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment
  delegated_subnet_id = module.virtual-network.db_subnet_id
  virtual_network_id  = module.virtual-network.id

  # Key vault must be created before database
  # TODO: Key vault is within the private link so we cannot access key vault from terraform
  administrator_login    = var.database_config.administrator_login
  administrator_password = var.database_config.administrator_password

  # Optional
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  postgres_version           = var.database_config.version
  storage_mb                 = var.database_config.storage_mb
  storage_tier               = var.database_config.storage_tier
  sku_name                   = var.database_config.sku_name

  tags = var.tags
}
