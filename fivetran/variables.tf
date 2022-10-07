#
# https://fivetran.com/docs/rest-api/destinations#payloadparameters
#
variable "region" {
  type        = string
  default     = "AWS_EU_CENTRAL_1"
  description = "Data processing location. This is where Fivetran will operate and run computation on data."
}

variable "time_zone_offset" {
  type        = string
  default     = "+2"
  description = "The time zone for the Fivetran sync schedule."
}

variable "project" {
  description = "name of your project or organisation"
  type        = string
}

variable "environment" {
  type = string
}

#
# Destination is the data warehouse, e.g. Snowflake
#
variable "destination_user_name" {
  type = string
}

variable "destination_role_arn" {
  type = string
}

variable "destination_host" {
  description = "e.g. 'your-account.snowflakecomputing.com'"
  type        = string
}

variable "destination_port" {
  type    = number
  default = 443
}

variable "destination_connection_type" {
  description = "Directly or SshTunnel"
  type        = string
  default     = "SshTunnel"
}

variable "destination_password" {
  description = "Password for the user on the database."
  type        = string
}

variable "destination_database_name" {
  type = string
}

variable "destination_service" {
  type        = string
  default     = "snowflake"
  description = "Name for the destination type: https://fivetran.com/docs/rest-api/destinations/config"
}

#
# Sources to connect to, e.g. AWS RDS, Google Analytics, etc.
#
variable "sources_rds" {
  description = "All RDS databases that we want to sync. Use a read-only user that has no access to PII data."
  default     = []

  type = list(object({
    host        = string
    port        = number
    database    = string
    user        = string
    password    = string
    tunnel_port = number
    tunnel_user = string
    tunnel_host = string
    # Supported values: WAL, XMIN, WAL_PGOUTPUT
    update_method    = string
    replication_slot = string
  }))
}

variable "sources_github" {
  description = "All Github Accounts that we want to sync. Use one user per account with access to that account only."
  default     = []

  type = list(object({
    organisation = string # name of the github org (as a pkey)
    sync_mode    = string # e.g. "SpecificRepositories"
    repositories = list(string)
    username     = string
    pat          = string
  }))
}

variable "sources_lambda" {
  description = "All lambda connector that we want to connect ot fivetran."
  default     = []

  type = list(object({
    service_name       = optional(string, null)
    project            = optional(string, null)
    environment        = optional(string, null)
    lambda_source_dir  = optional(string, null)
    lambda_output_path = optional(string, null)
    aws_region_code    = string
    script_env         = optional(map(any), {})
  }))
}

variable "lambda_settings" {
  description = "All lambda connector that we want to connect to fivetran."
  default     = {}
  type = object({
    lambda_role_arn        = optional(string, null) # Required for fivetran
    lambda_role_name       = optional(string, null) # Required if user want to setup the policy
    policy_arns_for_lambda = optional(list(string), [])
  })
}
