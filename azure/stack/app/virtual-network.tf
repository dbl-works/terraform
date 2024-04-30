# You can use an existing virtual network,
# but a dedicated subnet with a CIDR range of /23 or larger is required for use with Container Apps
module "virtual-network" {
  source = "../../virtual-network"

  resource_group_name           = var.resource_group_name
  region                        = var.region
  project                       = var.project
  environment                   = var.environment
  vnet_name                     = var.virtual_network_config.vnet_name
  public_subnet_name            = var.virtual_network_config.public_subnet_name
  private_subnet_name           = var.virtual_network_config.private_subnet_name
  db_subnet_name                = var.virtual_network_config.db_subnet_name
  network_interface_name_prefix = var.virtual_network_config.network_interface_name_prefix
  db_dns_zone_name              = var.virtual_network_config.db_dns_zone_name

  network_security_group_name_prefix = var.virtual_network_config.network_security_group_name_prefix
  network_security_group_name_suffix = var.virtual_network_config.network_security_group_name_suffix
  default_suffix                     = var.default_suffix

  # The resource which we would like to enable private link
  storage_account_id = module.observability.storage_account_id
  key_vault_id       = var.key_vault_id

  address_space = try(var.virtual_network_config.address_space, null)
  tags          = var.tags
}
