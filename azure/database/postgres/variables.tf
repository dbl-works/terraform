variable "resource_group_name" {
  type = string
}

# https://azure.microsoft.com/en-gb/explore/global-infrastructure/products-by-region/?products=postgresql
# West Europe doesn't support multiple AZ
variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "delegated_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "user_assigned_identity_ids" {
  type = list(string)
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id                     = string
    primary_user_assigned_identity_id    = string
    geo_backup_user_assigned_identity_id = string
  })
  default = null
}

variable "postgres_version" {
  type        = string
  default     = "16"
  description = "The version of PostgreSQL Flexible Server to use."
  nullable    = false
}

# | storage_mb | GiB  | TiB | Default | Supported storage_tier's         | Provisioned IOPS |
# |------------|------|-----|---------|---------------------------------|------------------|
# | 32768      | 32   | -   | P4      | P4, P6, P10, P15, P20, P30, P40, P50 | 120            |
# | 65536      | 64   | -   | P6      | P6, P10, P15, P20, P30, P40, P50     | 240            |
# | 131072     | 128  | -   | P10     | P10, P15, P20, P30, P40, P50         | 500            |
# | 262144     | 256  | -   | P15     | P15, P20, P30, P40, P50              | 1,100          |
# | 524288     | 512  | -   | P20     | P20, P30, P40, P50                   | 2,300          |
# | 1048576    | 1024 | 1   | P30     | P30, P40, P50                        | 5,000          |
# | 2097152    | 2048 | 2   | P40     | P40, P50                             | 7,500          |
# | 4193280    | 4095 | 4   | P50     | P50                                  | 7,500          |
# | 4194304    | 4096 | 4   | P50     | P50                                  | 7,500          |
# | 8388608    | 8192 | 8   | P60     | P60, P70                             | 16,000         |
# | 16777216   | 16384| 16  | P70     | P70, P80                             | 18,000         |
# | 33553408   | 32767| 32  | P80     | P80                                  | 20,000         |

# The storage_mb can only be scaled up.
variable "storage_mb" {
  type     = number
  default  = 32768
  nullable = false
}

variable "storage_tier" {
  type        = string
  default     = "P4"
  description = "Name of storage tier for IOPS. Default value for storage performance tier depends on the --storage-size selected for flexible server creation"
  validation {
    condition     = contains(["P4", "P6", "P10", "P15", "P20", "P30", " P40", "P50", " P60", "P70", "P80"], var.storage_tier)
    error_message = "Must be either P4, P6, P10, P15,P20, P30,P40, P50,P60, P70 or P80."
  }
  nullable = false
}

variable "create_mode" {
  type     = string
  default  = "Default"
  nullable = false
}

variable "db_subnet_address_prefixes" {
  type     = list(string)
  default  = ["10.0.1.0/24"]
  nullable = false
}

# Name: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage#compute-tiers-vcores-and-server-types
variable "sku_name" {
  # tier: The tier of the particular SKU, e.g. Burstable, GeneralPurpose, MemoryOptimized
  # The Burstable tier is best suited for low-cost development and low concurrency workloads without continuous compute capacity.
  # The General Purpose and Memory Optimized are better suited for production workloads requiring high concurrency, scale, and predictable performance.
  # Burstable: B, General Purpose: GP, MemoryOptimized: MO
  type        = string
  description = "The SKU Name for the PostgreSQL Flexible Server. Follows the tier + name pattern "
  default     = "GP_Standard_D2s_v3"
  nullable    = false
}

variable "administrator_login" {
  sensitive   = true
  type        = string
  description = "Admin username cannot start with numbers and must only contain characters and numbers, it also can not be root."
}

variable "administrator_password" {
  sensitive = true
  type      = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "db_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-region'."
}

variable "network_security_group_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-region-db'."
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-region-db-subnet'."
}

variable "dns_zone_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-region.postgres.database.azure.com'."
}

variable "log_retention_period" {
  type        = number
  default     = 1
  description = "Controls how long server log files are retained before being deleted (in day, must be between 1-7 days."
  nullable    = false

  validation {
    condition     = var.log_retention_period >= 1 && var.log_retention_period <= 7
    error_message = "Log retention period must be between 1-7 days."
  }
}

variable "log_min_error_statement" {
  type        = string
  default     = "panic"
  description = "Controls which SQL statements that cause an error condition are recorded in the server log."
  nullable    = false

  validation {
    condition     = contains(["debug5", "debug4", "debug3", "debug2", "debug1", "info", "notice", "warning", "error", "log", "fatal", "panic"], var.log_min_error_statement)
    error_message = "The valid values are [debug5, debug4, debug3, debug2, debug1, info, notice, warning, error, log, fatal, panic]"
  }
}

locals {
  default_name = "${var.project}-${var.environment}-${lower(replace(var.region, " ", "-"))}"

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
