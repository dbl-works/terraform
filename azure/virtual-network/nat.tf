# Private subnet only allow outbound internet access only via Nat Gateway
# resource "azurerm_public_ip" "main" {
#   name                = "${var.name}-Public-IP"
#   location                = var.region
#   resource_group_name     = var.resource_grou_name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   zones               = [1]
# }
#
# #Nat Gateway
# resource "azurerm_nat_gateway" "main" {
#   name                    = "${var.name}-NAT"
#   location                = var.region
#   resource_group_name     = var.resource_grou_name
#   sku_name                = "Standard"
#   idle_timeout_in_minutes = 10
#   zones                   = [1]
# }
#
# # Nat - Public IP Association
# resource "azurerm_nat_gateway_public_ip_association" "main" {
#   nat_gateway_id       = azurerm_nat_gateway.main.id
#   public_ip_address_id = azurerm_public_ip.main.id
# }
#
# # NAT - Subnets association
# resource "azurerm_subnet_nat_gateway_association" "main" {
#   subnet_id      = azurerm_subnet.private.id
#   nat_gateway_id = azurerm_nat_gateway.main.id
# }
#
