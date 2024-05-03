module "redis" {
  source = "../../redis"

  name                = var.redis_config.name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  region              = var.region
  project             = var.project

  # network
  public_network_access_enabled = var.redis_config.public_network_access_enabled
  subnet_id                     = module.virtual-network.private_subnet_id

  user_assigned_identity_ids = [
    data.azurerm_user_assigned_identity.main.id
  ]

  family                                = var.redis_config.family
  sku_name                              = var.redis_config.sku_name
  redis_version                         = var.redis_config.redis_version
  capacity                              = var.redis_config.capacity
  data_persistence_enabled              = var.redis_config.data_persistence_enabled
  data_persistence_frequency_in_minutes = var.redis_config.data_persistence_frequency_in_minutes
  data_persistence_max_snapshot_count   = var.redis_config.data_persistence_max_snapshot_count
  redis_additional_configuration        = var.redis_config.redis_additional_configuration
  shard_count                           = var.redis_config.shard_count
  zones                                 = var.redis_config.zones

  storage_name                                 = var.redis_config.storage_name
  data_persistence_storage_account_tier        = var.redis_config.data_persistence_storage_account_tier
  data_persistence_storage_account_replication = var.redis_config.data_persistence_storage_account_replication
}

output "redis" {
  value = module.redis
}
