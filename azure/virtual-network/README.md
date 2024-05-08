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
- Firewall subnet range: 10.0.150.0/24 (10.0.150.0 - 10.0.150.255)
- Bastion subnet range: 10.0.50.0/24 (10.0.50.0 - 10.0.50.255)

### Network Interface Name
- 0: Private
- 1: Key vault
- 2: Blob Storage

### Service endpoint VS Private endpoint
- With service endpoint, the traffic still left you VNet and hit the public endpoint of the PAAs resource
- Private link sit within your VNet and gets a private IP on your VNET

# https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links
## Virtual Network link

- After you create a private DNS zone in Azure, you'll need to link a virtual network to it. Once linked, VMs hosted in that virtual network can access the private DNS zone.
