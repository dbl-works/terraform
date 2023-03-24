resource "sentry_issue_alert" "main" {
  organization = var.sentry_organization
  project      = sentry_project.main.id
  name         = "Send a notification for new issues"

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
    },
  ]
}

# Retrieve a Slack integration
data "sentry_organization_integration" "slack" {
  organization = var.sentry_organization

  provider_key = "slack"
  name         = var.slack_workspace_name
}
