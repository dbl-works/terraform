# Terraform Module: Slack SNS

SNS used for Slack chatbot. SNS need to sit in the same region with the resources (e.g cloudwatch alarm) it attach to.

## Usage
```terraform
module "slack-sns" {
  source = "github.com/dbl-works/terraform//slack/sns?ref=v2021.07.05"

  # Optional
  sns_topic_name = "slack-sns"
}
```
