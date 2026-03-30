# Terraform Module: Slack

Creates Chatbot and SNS topic required to setup Slack message

## Usage
```terraform
module "slack-sns" {
  source = "github.com/dbl-works/terraform//aws/slack/sns?ref=main"

  # Optional
  sns_topic_name = "slack-sns"
}

module "chatbot" {
  source = "github.com/dbl-works/terraform//aws/slack/chatbot?ref=main"

  chatbot_name       = "facebook-staging-chatbot"

  # Optional
  slack_channel_id         = "CXXXXXXXXXX"
  slack_workspace_id       = "TXXXXXXXX"
  guardrail_policies       = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]
  sns_topic_arns           = [module.slack-sns.arn]
}
```
