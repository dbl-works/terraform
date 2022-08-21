resource "awscc_chatbot_slack_channel_configuration" "chatbot" {
  configuration_name = var.chatbot_name
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  user_role_required = false
  sns_topic_arns     = var.sns_topic_arns
  guardrail_policies = var.guardrail_policies
}

resource "aws_iam_role" "chatbot" {
  name = "aws-chatbot-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "management.chatbot.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
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
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "SNS:ListSubscriptionsByTopic",
          "SNS:ListTopics",
          "SNS:Unsubscribe",
          "SNS:Subscribe",
          "SNS:ListSubscriptions"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups"
        ],
        "Resource" : "arn:aws:logs:*:*:log-group:/aws/chatbot/*"
      }
    ]
  })
}
