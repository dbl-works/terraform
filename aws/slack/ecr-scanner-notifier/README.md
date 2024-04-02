# Terraform Module: ECR Scanner Slack Notifier

Slack notifier for AWS Elastic Container Registry (ECR) image scans. It automatically sends notifications to a designated Slack channel whenever vulnerabilities are detected in ECR scans.

## Usage

```terraform
module "ecr-scanner-notifier" {
  source = "github.com/dbl-works/terraform//slack/ecr-scanner-notifier?ref=v2023.03.06"

  project = local.project
  slack_webhook_url = "https://hooks.slack.com/services/x/y/z"
  slack_channel = "ecr-scanner"
}
```

## Pre-requisites

1. Setting up a [Slack App](https://api.slack.com/start/overview#creating).

2. [Configure](https://api.slack.com/messaging/sending) the Slack app for message sending.
