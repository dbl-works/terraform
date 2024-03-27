# https://github.com/hashicorp/terraform-provider-azurerm/issues/2186jk

# NOTE: A managed certificate couldn't be created by terraform yet
# resource "azurerm_container_app_custom_domain" "main" {
#   name                                     = trimprefix(azurerm_dns_txt_record.example.fqdn, "asuid.")
#   container_app_id                         = azurerm_container_app.main.id
#   container_app_environment_certificate_id = azurerm_container_app_environment_certificate.main.id
#   certificate_binding_type                 = "SniEnabled"
# }
#
