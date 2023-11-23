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
