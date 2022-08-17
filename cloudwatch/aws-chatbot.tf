resource "awscc_chatbot_slack_channel_configuration" "chatbot" {
  configuration_name = "${local.name}-chatbot"
  iam_role_arn       = aws_iam_role.cloudwatch_access_for_chatbot.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  user_role_required = false
  sns_topic_arns     = [aws_sns_topic.cloudwatch_slack.arn]
  guardrail_policies = []
}

resource "aws_iam_role" "cloudwatch_access_for_chatbot" {
  name = "cloudwatch_access_for_chatbot"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
  ]
}
