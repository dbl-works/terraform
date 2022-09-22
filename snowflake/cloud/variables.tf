variable "warehouse_name" {
  description = "All caps by convention of Snowflake."
  type        = string
}

# on AWS the minimum chargeable unit is 1 minute, after the first minute, billing is per second.
variable "suspend_compute_after_seconds" {
  description = "Specifies the number of seconds of inactivity after which a warehouse is automatically suspended."
  type        = number
  default     = 57
}

# https://docs.snowflake.com/en/user-guide/warehouses-overview.html
variable "warehouse_size" {
  type    = string
  default = "large"
}

variable "warehouse_cluster_count" {
  description = "The warehouse will auto-scale up to this number of clusters."
  type        = number
  default     = 1
}

#
# A retention period of 0 days for an object effectively disables Time Travel for the object.
#
variable "databases" {
  description = "List of databases to be created in Snowflake."
  type = list(object({
    name                   = string
    data_retention_in_days = number
  }))
}

variable "allowed_ip_list" {
  type = list(string)
  # If you are using fivetrans, check the list of IP addresses here: https://fivetran.com/docs/getting-started/ips#euregions
  # Default value is the fivetrans IP address in the EU region + using GCP as cloud provider
  # Note: The Snowflake user running terraform apply must be on an IP address allowed by the network policy to set the policy globally on the Snowflake account.
  default     = ["35.235.32.144/29"]
  description = "Comma-separated list of one or more IPv4 addresses that are allowed access to your Snowflake account."
}

variable "blocked_ip_list" {
  type    = list(string)
  default = []
}

variable "snowflake_users" {
  type        = list(string)
  description = "The users of which the network policy should be attached to"
  default     = []
}
