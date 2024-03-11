module "virtual-network" {
  source = "../virtual-network"

  name                = local.name
  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment

  address_space = try(var.virtual_network_config.address_space, null)
}

