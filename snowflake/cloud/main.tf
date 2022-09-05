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

# https://docs.snowflake.com/en/user-guide/network-policies.html
resource "snowflake_network_policy" "policy" {
  # The identifier must start with an alphabetic character
  # and cannot contain spaces or special characters unless the
  # entire identifier string is enclosed in double quotes (e.g. "My object").
  name    = "IpNetworkPolicy"
  comment = "Network policy to allow or deny access to a single IP address or a list of addresses."

  allowed_ip_list = var.allowed_ip_list
  blocked_ip_list = var.blocked_ip_list
}
