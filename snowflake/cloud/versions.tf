terraform {
  required_providers {
    snowflake = {
      source                = "Snowflake-Labs/snowflake"
      version               = ">= 0.42"
      configuration_aliases = [snowflake.security_admin]
    }
  }
}
