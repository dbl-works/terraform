module "fivetran" {
  source = "../fivetran"

  # https://fivetran.com/docs/rest-api/connectors/config#postgres
  sources_rds    = var.sources_rds
  sources_github = var.sources_github

  # https://fivetran.com/docs/rest-api/destinations/config#snowflake
  destination_service         = "snowflake"
  time_zone_offset            = var.time_zone_offset
  region                      = var.region
  destination_host            = var.destination_host
  destination_port            = var.destination_port
  destination_database_name   = var.destination_database_name
  destination_user_name       = var.destination_user_name
  destination_password        = var.destination_password
  destination_connection_type = var.destination_connection_type

  environment = local.environment
  project     = local.project

  fivetran_api_key    = var.fivetran_api_key
  fivetran_api_secret = var.fivetran_api_secret
}
