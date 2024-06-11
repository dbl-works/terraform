# For example, a system topic may represent all blob events or only blob created and blob deleted events published for a specific storage account.
# when a blob is uploaded to the storage account, the Azure Storage service publishes a blob created event to the system topic in Event Grid,
# which then forwards the event to topic's subscribers that receive and process the event.
resource "azurerm_eventgrid_system_topic" "main" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.region
  source_arm_resource_id = azurerm_storage_account.main.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  tags = var.tags
}
