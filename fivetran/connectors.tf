# get db url: https://docs.snowflake.com/en/sql-reference/functions/system_get_privatelink_config.html
resource "fivetran_connector" "rds" {
  for_each = { for rds in var.sources_rds : rds.host => rds }

  group_id          = fivetran_destination.main.group_id
  service           = "postgres_rds" # https://fivetran.com/docs/rest-api/connectors/config#postgres
  sync_frequency    = 60             # mins, supported values: 5, 15, 30, 60, 120, 180, 360, 480, 720, 1440.
  paused            = false
  pause_after_trial = false

  destination_schema {
    name = "aws_rds_${each.value.database}" # name shown on Fivetran UI
  }

  # https://fivetran.com/docs/rest-api/connectors/config#configparameters_112
  config {
    host             = each.value.host
    port             = each.value.port
    database         = each.value.database
    user             = each.value.user
    password         = each.value.password
    tunnel_port      = each.value.tunnel_port
    tunnel_user      = each.value.tunnel_user
    update_method    = each.value.update_method
    replication_slot = each.value.replication_slot
  }
}



resource "fivetran_connector" "github" {
  for_each = { for github in var.sources_github : github.organisation => github }

  group_id          = fivetran_group.group.id
  service           = "github"
  sync_frequency    = 60
  paused            = false
  pause_after_trial = false
  run_setup_tests   = true

  destination_schema {
    name = "github_${each.value.organisation}" # name shown on Fivetran UI
  }

  config {
    sync_mode    = each.value.sync_mode
    repositories = each.value.repositories
    use_webhooks = true
    auth_mode    = "PersonalAccessToken"
    username     = each.value.username
    pat          = each.value.pat
  }
}
