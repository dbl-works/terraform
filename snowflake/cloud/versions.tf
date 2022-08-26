terraform {
  required_providers {
    snowflake = {
      source                = "Snowflake-Labs/snowflake"
      version               = "~> 0.35"
      configuration_aliases = [snowflake.security_admin]
    }
  }
}

provider "snowflake" {
  role = "SYSADMIN"

  username = var.snowflake_user # $ export TF_VAR_snowflake_user=<username>
  account  = var.snowflake_account
  region   = var.snowflake_region

  # For auth exactly one option must be set.
  private_key_passphrase = var.snowflake_private_key_path
}

provider "snowflake" {
  role  = "SECURITYADMIN"
  alias = "security_admin"

  username = var.snowflake_user # $ export TF_VAR_snowflake_user=<username>
  account  = var.snowflake_account
  region   = var.snowflake_region

  # For auth exactly one option must be set.
  private_key_passphrase = var.snowflake_private_key_path
}

# these variables are set via `source .env` which sets environment variables.
variable "snowflake_user" {
  type = string
}

variable "snowflake_private_key_path" {
  type = string
}

variable "snowflake_account" {
  type = string
}

variable "snowflake_region" {
  type = string
}
