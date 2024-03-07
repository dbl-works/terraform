# The terraform module does not (yet) expose the `public_network_access` setting. We want to make sure it's disabled by default.
# thus for now all we can do is log it, and worst case adjust manually.
output "public_network_access_enabled" {
  value = azurerm_postgresql_flexible_server.main.public_network_access_enabled
}
