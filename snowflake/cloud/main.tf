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

  max_cluster_count = var.multi_cluster_warehouses_enabled ? var.warehouse_cluster_count : null
  min_cluster_count = var.multi_cluster_warehouses_enabled ? 1 : null         # if set to less than max count, auto-scaling is enabled
  scaling_policy    = var.multi_cluster_warehouses_enabled ? "ECONOMY" : null # Conserves credits by favoring keeping running clusters fully-loaded
}

locals {
  network_policy_name = "IpNetworkPolicy"
}

#
# when using "SECURITYADMIN" + "SYSADMIN" roles, which should be suffcient, see https://docs.snowflake.com/en/sql-reference/sql/create-network-policy.html
#
# │ Error: error creating network policy IpNetworkPolicy: 003001 (42501): SQL access control error:
# │ Insufficient privileges to operate on account 'IL49394'
# │
# │   with module.snowflake_cloud.snowflake_network_policy.policy,
# │   on .terraform/modules/snowflake_cloud/main.tf line 27, in resource "snowflake_network_policy" "policy":
# │   27: resource "snowflake_network_policy" "policy" {
# │
# ╵
# ╷
# │ Error: error creating attachment for network policy IpNetworkPolicy: error setting network policy IpNetworkPolicy on account: 003001 (42501): SQL access control error:
# │ Insufficient privileges to operate on account 'IL49394'
# │
# │   with module.snowflake_cloud.snowflake_network_policy_attachment.attach,
# │   on .terraform/modules/snowflake_cloud/main.tf line 39, in resource "snowflake_network_policy_attachment" "attach":
# │   39: resource "snowflake_network_policy_attachment" "attach" {



# https://docs.snowflake.com/en/user-guide/network-policies.html
# resource "snowflake_network_policy" "policy" {
#   # The identifier must start with an alphabetic character
#   # and cannot contain spaces or special characters unless the
#   # entire identifier string is enclosed in double quotes (e.g. "My object").

#   name    = local.network_policy_name
#   comment = "Network policy to allow or deny access to a single IP address or a list of addresses."

#   allowed_ip_list = var.allowed_ip_list
#   blocked_ip_list = var.blocked_ip_list
# }

# resource "snowflake_network_policy_attachment" "attach" {
#   network_policy_name = local.network_policy_name
#   # A Snowflake account can only have one network policy set globally at any given time.
#   # This resource does not enforce one-policy-per-account, it is the user's responsibility to enforce this.
#   # If multiple network policy resources have set_for_account: true,
#   # the final policy set on the account will be non-deterministic.
#   set_for_account = true
#   users           = var.snowflake_users
# }
