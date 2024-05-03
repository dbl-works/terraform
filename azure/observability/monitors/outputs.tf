output "storage_account_id" {
  value = module.blob-storage.id
}

output "storage_account_name" {
  value = module.blob-storage.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}
