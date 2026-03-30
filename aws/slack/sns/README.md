# Terraform Module: Slack SNS

SNS used for Slack chatbot. SNS need to sit in the same region with the resources (e.g cloudwatch alarm) it attach to.

## Usage
```terraform
module "slack-sns" {
  source = "github.com/dbl-works/terraform//aws/slack/sns?ref=main"

  # Optional
  sns_topic_name = "slack-sns"
}
```
