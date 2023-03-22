# Terraform Module: ECR Scanner Slack Notifier

A repository for storing built docker images.


## Usage

```terraform
module "ecr" {
  source = "github.com/dbl-works/terraform//slack/ecr-scanner-notifier?ref=v2023.03.06"

  project = local.project
  environment = "staging"
  slack_webhook_url = "https://hooks.slack.com/services/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  slack_channel = "ecr-scanner"
}
```
