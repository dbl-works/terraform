# Terraform Module: Slack Chatbot

Setup AWS chatbot that will pick SNS message from the SNS topic and sent them to selected Slack channel

## Usage
1. Before applying the terraform changes, you must [Configure a Slack Client](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html) on AWS Chatbot.

2.To retrieve your Slack channel ID and Workspace ID, visit your [workspace Slack URL](https://slack.com/help/articles/221769328-Locate-your-Slack-URL-or-ID).

```terraform
module "chatbot" {
  source = "github.com/dbl-works/terraform//aws/slack/chatbot?ref=main"

  chatbot_name       = "facebook-staging-chatbot"

  # Optional
  slack_channel_id         = "CXXXXXXXXXX"
  slack_workspace_id       = "TXXXXXXXX"
  guardrail_policies       = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]
  sns_topic_arns           = ["arn:aws:sns:eu-central-1:122222222222:slack-sns"]
}
```
