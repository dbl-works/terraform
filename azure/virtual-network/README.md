# Azure Virtual Network

https://azure.microsoft.com/de-de/products/virtual-network

Creates a virtual network in Azure account. Also generates a group of public and private subnets.

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

### List of address prefixes ranges
Assuming address space is 10.0.0.0/16
- Public subnet range: 10.0.2.0/23 (10.0.1.0 - 10.0.2.255)
- Private subnet range: 10.0.100.0/24 (10.0.100.0 - 10.0.100.255)
- DB subnet range: 10.0.200.0/24 (10.0.200.0 - 10.0.200.255)
- Redis subnet range: 10.0.150.0/24 (10.0.150.0 - 10.0.150.255)
- Bastion subnet range: 10.0.50.0/24 (10.0.50.0 - 10.0.50.255)
