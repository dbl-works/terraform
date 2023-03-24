# Terraform Module: Slack Notifier for Sentry isseus

Sending message to Slack when there is new sentry issues


## Usage

```terraform
module "sentry_slack_alert" {
  source = "github.com/dbl-works/terraform//ecr?ref=v2023.03.06"

  project = "metaverse"
  sentry_organization = "facebook"
  slack_workspace_name = "facebook-slack"

  # Optional
  frequency = 30
}
```
