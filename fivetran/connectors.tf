# get db url: https://docs.snowflake.com/en/sql-reference/functions/system_get_privatelink_config.html
resource "fivetran_connector" "rds" {
  for_each = { for rds in var.sources_rds : rds.host => rds }

  group_id = fivetran_destination.main.group_id
  service  = "postgres_rds" # https://fivetran.com/docs/rest-api/connectors/config#postgres

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
    update_method    = each.value.update_method
    replication_slot = each.value.replication_slot

    # access to the DB should be restricted. We use a bastion jump host to access the DB.
    tunnel_port = each.value.tunnel_port
    tunnel_user = each.value.tunnel_user
    tunnel_host = each.value.tunnel_host
  }
}

resource "fivetran_connector_schedule" "rds" {
  for_each = { for rds_connector in fivetran_connector.rds : rds_connector.id => rds_connector }

  connector_id = each.key

  sync_frequency  = "60"
  daily_sync_time = "03:00"

  paused            = false
  pause_after_trial = false

  schedule_type = "auto"
}


resource "fivetran_connector" "github" {
  for_each = { for github in var.sources_github : github.organisation => github }

  group_id        = fivetran_group.group.id
  service         = "github"
  run_setup_tests = true

  destination_schema {
    name = "github_${replace(each.value.organisation, "/[^0-9A-Za-z_]/", "_")}" # name shown on Fivetran UI
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

resource "fivetran_connector_schedule" "github" {
  for_each = { for github_connector in fivetran_connector.github : github_connector.id => github_connector }

  connector_id = each.key

  sync_frequency  = "60"
  daily_sync_time = "03:00"

  paused            = false
  pause_after_trial = false

  schedule_type = "auto"
}

module "lambda_connector" {
  for_each = { for lambda in var.sources_lambda : join("-", compact([lambda.service_name, lambda.project, lambda.environment])) => lambda }
  source   = "./connectors/lambda"

  providers = {
    fivetran = fivetran
  }

  # required
  fivetran_group_id = fivetran_group.group.id # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  project           = each.value.project      # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  environment       = each.value.environment  # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)

  # optional
  service_name       = each.value.service_name
  aws_region_code    = each.value.aws_region_code          # lambda's aws region
  lambda_role_arn    = var.lambda_settings.lambda_role_arn # Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created.
  lambda_source_dir  = each.value.lambda_source_dir
  lambda_output_path = each.value.lambda_output_path
  script_env         = each.value.script_env
}

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  count      = lookup(var.lambda_settings, "lambda_role_name", null) == null ? 0 : length(var.lambda_settings.policy_arns_for_lambda)
  role       = var.lambda_settings.lambda_role_name
  policy_arn = var.lambda_settings.policy_arns_for_lambda[count.index]
}
