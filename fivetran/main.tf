resource "fivetran_group" "group" {
  name = "${var.project}_${var.environment}_${var.region}"
}

# resource "fivetran_connector_schema_config" "schema" {
#   connector_id = fivetran_connector.rds.id # the ID of the connector whose standard config is managed by the resource
#   # TODO: verify this
#   schema_change_handling = "ALLOW_ALL"

#   # TODO: verify this
#   schema {
#     name = var.schema_name
#     table {
#       name = "table_name"
#       column {
#         name   = "hashed_column_name"
#         hashed = "true"
#       }
#       column {
#         name    = "blocked_column_name"
#         enabled = "false"
#       }
#     }
#     table {
#       name    = "blocked_table_name"
#       enabled = "false"
#     }
#   }
# }

resource "fivetran_destination" "main" {
  group_id           = fivetran_group.group.id
  service            = var.destination_service
  time_zone_offset   = var.time_zone_offset
  region             = var.region # https://fivetran.com/docs/rest-api/destinations#payloadparameters
  trust_certificates = "true"
  trust_fingerprints = "true"
  run_setup_tests    = "true" # checks if we can reach the destination

  # https://fivetran.com/docs/rest-api/destinations/config#snowflake
  # https://fivetran.com/docs/rest-api/destinations/config#configparameters
  config {
    host            = var.destination_host
    port            = var.destination_port
    database        = var.destination_database_name
    user            = var.destination_user_name
    password        = var.destination_password
    auth            = "PASSWORD"
    connection_type = var.destination_connection_type
  }
}
