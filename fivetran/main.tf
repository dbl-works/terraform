resource "fivetran_group" "group" {
  name = var.fivetran_group_name
}

resource "fivetran_connector" "rds" {
  group_id          = fivetran_destination.main.group_id
  service           = var.source_service
  sync_frequency    = 60 # mins, supported values: 5, 15, 30, 60, 120, 180, 360, 480, 720, 1440.
  paused            = false
  pause_after_trial = false

  destination_schema {
    # Has to be unique within the group (destination)
    name   = var.schema_name
    prefix = var.db_config.schema_prefix
  }

  # https://fivetran.com/docs/rest-api/connectors/config#configparameters_112
  config {
    host        = var.db_config.host
    port        = var.db_config.port
    database    = var.db_config.database
    user        = var.db_config.user
    password    = var.db_config.password
    tunnel_port = var.db_config.tunnel_port
    tunnel_user = var.db_config.tunnel_user
    # Supported values: WAL, XMIN, WAL_PGOUTPUT
    update_method    = var.db_config.update_method
    replication_slot = var.db_config.replication_slot
  }
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
  service            = var.destionation_service
  time_zone_offset   = var.time_zone_offset
  region             = var.region # https://fivetran.com/docs/rest-api/destinations#payloadparameters
  trust_certificates = "true"
  trust_fingerprints = "true"
  run_setup_tests    = "true"

  config {
    # https://fivetran.com/docs/rest-api/destinations/config#snowflake
    host     = "your-account.snowflakecomputing.com"
    port     = 443
    database = var.destination_database_name
    user     = var.destination_user_name
    password = var.destination_password
    # https://fivetran.com/docs/rest-api/destinations/config#configparameters
    connection_type = "SshTunnel" # Directly or SshTunnel
  }
}
