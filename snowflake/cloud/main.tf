resource "snowflake_database" "main" {
  for_each = { for database in var.databases : database.name => database }

  name                        = each.value.name
  data_retention_time_in_days = each.value.data_retention_in_days
}



resource "snowflake_warehouse" "main" {
  name           = var.warehouse_name
  warehouse_size = var.warehouse_size

  auto_suspend = var.suspend_compute_after_seconds
  auto_resume  = true

  max_cluster_count = var.warehouse_cluster_count
  min_cluster_count = 1         # if set to less than max count, auto-scaling is enabled
  scaling_policy    = "ECONOMY" # Conserves credits by favoring keeping running clusters fully-loaded
}
