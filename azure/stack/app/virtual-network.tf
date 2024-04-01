# You can use an existing virtual network,
# but a dedicated subnet with a CIDR range of /23 or larger is required for use with Container Apps
module "virtual-network" {
  source = "../../virtual-network"

  resource_group_name                 = var.resource_group_name
  region                              = var.region
  project                             = var.project
  environment                         = var.environment
  vnet_name                           = var.virtual_network_config.vnet_name
  public_subnet_name                  = var.virtual_network_config.public_subnet_name
  private_subnet_name                 = var.virtual_network_config.private_subnet_name
  db_subnet_name                      = var.virtual_network_config.db_subnet_name
  db_network_security_group_name      = var.virtual_network_config.db_network_security_group_name
  public_network_security_group_name  = var.virtual_network_config.public_network_security_group_name
  private_network_security_group_name = var.virtual_network_config.private_network_security_group_name
  network_interface_name              = var.virtual_network_config.network_interface_name
  db_dns_zone_name                    = var.virtual_network_config.db_dns_zone_name

  address_space = try(var.virtual_network_config.address_space, null)
  tags          = var.tags
}
