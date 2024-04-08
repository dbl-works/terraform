# Granting access to deploybot
# data "azurerm_user_assigned_identity" "deploybot" {
#   name                = "deploybot"
#   resource_group_name = var.resource_group_name
# }
#
# resource "azurerm_role_assignment" "container-registry" {
#   scope                = module.container-registry.id
#   role_definition_name = "acrpull"
#   principal_id         = data.azurerm_user_assigned_identity.deploybot.principal_id
# }
#
# resource "azurerm_role_assignment" "container-app" {
#   scope                = module.container-app.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.deploybot.principal_id
# }
#
