module "database" {
  source = "../../database/postgres"

  db_name             = var.database_config.name
  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment
  virtual_network_id  = module.virtual-network.id
  virtual_network_name = var.virtual_network_config.vnet_name
  log_analytics_workspace_name = module.observability.log_analytics_workspace_name

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

  subnet_name                     = var.database_config.subnet_name
  private_dns_zone_name          = var.database_config.private_dns_zone_name
  network_security_group_name_prefix = var.virtual_network_config.network_security_group_name_prefix
  network_security_group_name_suffix = var.virtual_network_config.network_security_group_name_suffix
  network_watcher_name                = var.virtual_network_config.network_watcher_name
  storage_account_id_for_network_logging = module.observability.storage_account_id

  tags = var.tags
}
