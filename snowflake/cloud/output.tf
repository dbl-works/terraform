output "warehouse_id" {
  value = snowflake_warehouse.main.id
}

output "database_ids" {
  value = values(snowflake_database.main).*.id
}
