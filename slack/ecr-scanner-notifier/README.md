# Terraform Module: ECR Scanner Slack Notifier

Slack notifier for ECR scan


## Usage

```terraform
module "ecr-scanner-notifier" {
  source = "github.com/dbl-works/terraform//slack/ecr-scanner-notifier?ref=v2023.03.06"

  project = local.project
  slack_webhook_url = "https://hooks.slack.com/services/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  slack_channel = "ecr-scanner"
}
```
