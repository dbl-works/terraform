# resource "azurerm_subnet" "bastion" {
#   count = var.enable_bastion ? 1 : 0
#
#   # The name of the Subnet for "ip_configuration.0.subnet_id" must be exactly 'AzureBastionSubnet' to be used for the Azure Bastion Host resource
#   name                 = "AzureBastionSubnet"
#   virtual_network_name = azurerm_virtual_network.main.name
#   resource_group_name  = var.resource_group_name
#   # i.e. 10.0.50.0/24, range 10.0.50.0 - 10.0.50.255
#   address_prefixes = [cidrsubnet(var.address_space, 8, 50)]
# }
#
# # https://learn.microsoft.com/en-us/azure/bastion/bastion-overview
# # You don't need to apply any NSGs to the Azure Bastion subnet.
# # Because Azure Bastion connects to your virtual machines over private IP,
# # you can configure your NSGs to allow RDP/SSH from Azure Bastion only.
# # This removes the hassle of managing NSGs each time you need to securely connect to your virtual machines.
#
# # The azurerm_network_watcher_flow_log creates a new storage lifecyle management rule that overwrites existing rules.
# # Please make sure to use a storage_account with no existing management rules, until the issue is fixed.
# resource "azurerm_network_watcher_flow_log" "bastion" {
#   count = var.enable_bastion ? 1 : 0
#
#   name                 = "${azurerm_network_security_group.bastion[0].name}-flow-log"
#   network_watcher_name = var.network_watcher_name
#   resource_group_name  = var.resource_group_name
#
#   network_security_group_id = azurerm_network_security_group.bastion[0].id
#   storage_account_id        = var.storage_account_for_network_logging
#   enabled                   = true
#
#   retention_policy {
#     enabled = true
#     days    = 90
#   }
#
#   traffic_analytics {
#     enabled               = true
#     workspace_id          = data.azurerm_log_analytics_workspace.main.workspace_id
#     workspace_region      = data.azurerm_log_analytics_workspace.main.location
#     workspace_resource_id = data.azurerm_log_analytics_workspace.main.id
#     interval_in_minutes   = 10
#   }
# }
#
# resource "azurerm_public_ip" "bastion" {
#   count = var.enable_bastion ? 1 : 0
#
#   name                = "public-ip-${local.default_suffix}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
# resource "azurerm_bastion_host" "main" {
#   count               = var.enable_bastion ? 1 : 0
#   name                = "bastion-host-${local.default_suffix}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#
#   ip_configuration {
#     name                 = "bas-configuration"
#     subnet_id            = azurerm_subnet.bastion[0].id
#     public_ip_address_id = azurerm_public_ip.bastion[0].id
#   }
#
#   tags = coalesce(var.tags, local.default_tags)
# }

# resource "azurerm_windows_virtual_machine" "bastion" {
#   count = var.enable_bastion ? 1 : 0
#
#   # "computer_name" can be at most 15 characters
#   name                = "vm-${local.default_suffix}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   admin_password      = "Password123!!"
#   network_interface_ids = [
#     azurerm_network_interface.private.id,
#   ]
#
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
#
#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
