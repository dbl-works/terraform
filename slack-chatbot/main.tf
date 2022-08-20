resource "awscc_chatbot_slack_channel_configuration" "chatbot" {
  configuration_name = var.chatbot_name
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  user_role_required = false
  sns_topic_arns     = [aws_sns_topic.slack.arn]
  guardrail_policies = var.guardrail_policies
}

resource "aws_iam_role" "chatbot" {
  name = "aws-chatbot-role"

  assume_role_policy = jsonencode({
    "version" : "2012-10-17",
    "statement" : [
      {
        "effect" : "allow",
        "principal" : {
          "service" : "management.chatbot.amazonaws.com"
        },
        "action" : "sts:assumerole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot_policy.arn
}

resource "aws_iam_policy" "chatbot_policy" {
  name = "chatbot-policy"

  policy = jsonencode({
    "version" : "2012-10-17",
    "statement" : [
      {
        "action" : [
          "SNS:ListSubscriptionsByTopic",
          "SNS:ListTopics",
          "SNS:Unsubscribe",
          "SNS:Subscribe",
          "SNS:ListSubscriptions"
        ],
        "effect" : "allow",
        "resource" : "*"
      },
      {
        "effect" : "allow",
        "action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups"
        ],
        "resource" : "arn:aws:logs:*:*:log-group:/aws/chatbot/*"
      }
    ]
  })
}
