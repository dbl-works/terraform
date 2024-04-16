locals {
  db_parameters = {
    "azure.extensions"        = "pgcrypto",
    "log_statement"           = "none"
    "log_min_error_statement" = var.log_min_error_statement
    "logfiles.retention_days" = var.log_retention_period

    "wal_buffers" = -1 # Sets the number of disk-page buffers in shared memory for WAL. Unit is 8kb.
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "main" {
  for_each = local.db_parameters

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = each.value
}
