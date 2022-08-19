# Terraform Module: Slack Chatbot

Setup AWS chatbot that will send SNS message to selected Slack channel

## Usage
```terraform
module "chatbot" {
  source = "github.com/dbl-works/terraform//slack-chatbot?ref=v2021.07.05"

  chatbot_name       = "facebook-staging-chatbot"
  sns_topic_name     = "facebook-staging-cloudwatch-slack"

  # Optional
  slack_channel_id         = "CXXXXXXXXXX"
  slack_workspace_id       = "TXXXXXXXX"
  guardrail_policies       = ["arn:aws:iam::aws:policy/cloudwatchreadonlyaccess"]
}
```
