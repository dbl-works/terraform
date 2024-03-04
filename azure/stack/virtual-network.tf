module "virtual-network" {
  source = "../virtual-network"

  name                = local.name
  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment

  address_spaces = var.virtual_network_config.address_spaces
  subnet_config = {
    "subnet1" = {
      address_prefixes = []
      rules = {
        priority               = 1
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        source_port_range      = "*"
        destination_port_range = var.container_app_config.target_port
        source_address_prefix  = ["0.0.0.0/0"]
      }

    }
  }
}
