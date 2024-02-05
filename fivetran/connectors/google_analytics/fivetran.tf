locals {
  name             = "google_analytics_${var.project}"
  auth_credentials = var.auth == null ? [] : [var.auth]
}

resource "fivetran_connector" "google_analytics" {
  group_id        = var.fivetran_group_id
  service         = "google_analytics"
  run_setup_tests = true

  destination_schema {
    name = local.name
  }

  config {
    sync_mode        = "SpecificAccounts"
    accounts         = var.google_account_ids
    profiles         = var.google_profile_ids
    timeframe_months = var.timeframe_months # TWELVE, SIX, ALL_TIME, TWENTY_FOUR, THREE

    dynamic "reports" {
      for_each = { for report in var.reports : report.table => report }

      content {
        table           = reports.key
        config_type     = reports.value.config_type
        prebuilt_report = reports.value.prebuilt_report
      }
    }
  }

  dynamic "auth" {
    for_each = { for cred in local.auth_credentials : cred.client_id => cred }

    content {
      client_access {
        client_id     = auth.key
        client_secret = auth.value.client_secret
      }
      refresh_token = auth.value.refresh_token
    }
  }
}

resource "fivetran_connector_schedule" "lambda" {
  connector_id = fivetran_connector.lambda.id

  sync_frequency  = var.sync_frequency
  daily_sync_time = "03:00"

  paused            = false
  pause_after_trial = false

  schedule_type = "auto"
}
