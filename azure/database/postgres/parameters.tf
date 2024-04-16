locals {
  db_parameters = {
    "azure.extensions"         = "pgcrypto",
    "log_statement"            = "none"
    "rds.force_ssl"            = 1
    "rds.log_retention_period" = var.log_retention_period
    "log_min_error_statement"  = var.log_min_error_statement

    "rds.logical_replication" = var.enable_replication ? 1 : 0
    "wal_sender_timeout"      = var.enable_replication ? 0 : 60000 # default, 1 min
    "wal_buffers"             = -1
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "main" {
  for_each = local.db_parameters

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = each.value
}
