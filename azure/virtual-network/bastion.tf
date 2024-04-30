resource "azurerm_subnet" "bastion" {
  count = var.enable_bastion ? 1 : 0

  # The name of the Subnet for "ip_configuration.0.subnet_id" must be exactly 'AzureBastionSubnet' to be used for the Azure Bastion Host resource
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  # i.e. 10.0.50.0/24, range 10.0.50.0 - 10.0.50.255
  address_prefixes = [cidrsubnet(var.address_space, 8, 50)]
}

resource "azurerm_public_ip" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                = "public-ip-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_bastion_host" "main" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bastion-host-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = coalesce(var.tags, local.default_tags)

  ip_configuration {
    name                 = "bas-configuration"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

resource "azurerm_windows_virtual_machine" "bastion" {
  count = var.enable_bastion ? 1 : 0

  # "computer_name" can be at most 15 characters
  name                = "vm-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Password123!!"
  network_interface_ids = [
    azurerm_network_interface.private.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
