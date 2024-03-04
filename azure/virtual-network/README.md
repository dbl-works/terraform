# Azure Virtual Network

https://azure.microsoft.com/de-de/products/virtual-network

Creates a virtual network in Azure account. Also generates a group fo public and private subnets.

```
module "virtual-network" {
  source = "../virtual-network"

  name                = local.name
  resource_group_name = var.resource_group_name
  region              = var.region
  project             = var.project
  environment         = var.environment

  address_space = "10.0.0.0/16"
  private_subnet_config = {}
  public_subnet_config = {
    priority               = 1
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = 3000
    source_address_prefix  = ["0.0.0.0/0"]
  }
}
```
