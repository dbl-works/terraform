module "sentry_slack_alert" {
  for_each = var.sentry_config

  source = "../../slack/sentry"

  project              = var.project
  sentry_organization  = each.value.organization_name
  slack_workspace_name = each.value.slack_workspace_name
  sentry_project_slug  = each.key
  platform             = each.value.platform
  sentry_teams         = each.value.sentry_teams
  frequency            = each.value.frequency
}
