resource "aws_sns_topic" "cloudwatch_slack" {
  name = "${local.name}-cloudwatch-slack"
}

resource "aws_sns_topic_policy" "cloudwatch_slack" {
  arn = aws_sns_topic.cloudwatch_slack.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [local.account_id]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.cloudwatch_slack.arn]
  }
}
