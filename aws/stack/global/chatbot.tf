module "chatbot" {
  count  = var.chatbot_config == null ? 0 : 1
  source = "../../slack/chatbot"

  chatbot_name = "${var.project}-chatbot"

  # Optional
  slack_channel_id   = var.chatbot_config.slack_channel_id
  slack_workspace_id = var.chatbot_config.slack_workspace_id
  guardrail_policies = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]
  sns_topic_arns = [
    module.slack-sns.arn
  ]
}
