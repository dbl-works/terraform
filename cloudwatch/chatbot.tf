module "chatbot" {
  count  = var.slack_channel_id != null && var.slack_workspace_id != null ? 1 : 0
  source = "../slack-chatbot"

  sns_topic_name     = "${local.name}-cloudwatch-slack"
  chatbot_name       = "${local.name}-chatbot"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  guardrail_policies = ["arn:aws:iam::aws:policy/cloudwatchreadonlyaccess"]
}