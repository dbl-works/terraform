resource "awscc_chatbot_slack_channel_configuration" "chatbot" {
  configuration_name = var.chatbot_name
  iam_role_arn       = awscc_iam_role.chatbot.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  user_role_required = false
  sns_topic_arns     = var.sns_topic_arns
  guardrail_policies = var.guardrail_policies
}

resource "awscc_iam_role" "chatbot" {
  role_name = "aws-chatbot-role"

  assume_role_policy_document = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "chatbot.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.chatbot_policy]
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
        "Action" : [
          "cloudwatch:List*",
          "cloudwatch:Get*"
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
