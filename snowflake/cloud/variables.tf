variable "account_name" {
  description = "Name of either the project of the company you want to set up a Snowflake Warehouse for."
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
variable "projects" {
  description = "List of projects to create Snowflake Databases for."
  type = list(object({
    name                   = string
    data_retention_in_days = number
  }))
}
