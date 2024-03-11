# You can use an existing virtual network,
# but a dedicated subnet with a CIDR range of /23 or larger is required for use with Container Apps
module "virtual-network" {
  source = "../virtual-network"

  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment

  address_space = try(var.virtual_network_config.address_space, null)
}

