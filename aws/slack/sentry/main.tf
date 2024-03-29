resource "sentry_project" "main" {
  count        = var.sentry_project_slug == null ? 1 : 0
  organization = var.sentry_organization

  teams = var.sentry_teams
  name  = local.sentry_project_name
  slug  = local.sentry_project_name

  platform    = var.platform
  resolve_age = var.resolve_age
}

resource "sentry_issue_alert" "main" {
  organization = var.sentry_organization
  project      = var.sentry_project_slug == null ? local.sentry_project_name : var.sentry_project_slug
  name         = "Send a slack notification for new issues"

  action_match = "any"
  filter_match = "any"
  frequency    = var.frequency

  conditions = [
    {
      # A new issue is created
      id = "sentry.rules.conditions.first_seen_event.FirstSeenEventCondition"
    },
  ]

  filters = []

  actions = [
    # Send a notification to the Slack workspace
    {
      id      = "sentry.integrations.slack.notify_action.SlackNotifyServiceAction"
      channel = "#ops-${var.project}"

      # From: https://sentry.io/settings/[org-slug]/integrations/slack/[slack-integration-id]/
      # Or use the sentry_organization_integration data source to retrieve the integration ID:
      workspace = data.sentry_organization_integration.slack.internal_id
      tags      = var.tags
    },
  ]

  depends_on = [
    sentry_project.main
  ]
}

# Retrieve a Slack integration
data "sentry_organization_integration" "slack" {
  organization = var.sentry_organization

  provider_key = "slack"
  name         = var.slack_workspace_name
}

locals {
  sentry_project_name = var.sentry_project_name == null ? "${var.project}-api" : var.sentry_project_name
}
