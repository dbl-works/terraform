resource "aws_cloudformation_stack" "chatbot_slack_config" {
  name = "aws-chatbot-slack-config"

  template_body = jsonencode({
    Resources = {
      SlackChannelConfiguration = {
        Type = "AWS::Chatbot::SlackChannelConfiguration"
        Properties = {
          ConfigurationName = var.chatbot_name
          IamRoleArn        = aws_iam_role.chatbot.arn
          SlackChannelId    = var.slack_channel_id
          SlackWorkspaceId  = var.slack_workspace_id
          SnsTopicArns      = var.sns_topic_arns
        }
      }
    }
  })

  capabilities = ["CAPABILITY_IAM"]
}

resource "aws_iam_role" "chatbot" {
  name = "aws_chatbot_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "chatbot_policy_attachment" {
  policy_arn = aws_iam_policy.chatbot_policy.arn
  role       = aws_iam_role.chatbot.name
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
