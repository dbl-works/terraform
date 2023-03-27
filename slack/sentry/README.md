# Terraform Module: Slack Notifier for Sentry isseus

Sending message to Slack when there is new sentry issues


## Usage

```terraform
module "sentry_slack_alert" {
  source = "github.com/dbl-works/terraform//slack/sentry?ref=v2023.03.06"

  project = "metaverse"
  sentry_organization = "facebook"
  slack_workspace_name = "facebook-slack"

  # Optional
  frequency = 30
  sentry_project_slug = "123456"
  sentry_project_name = "facebook-api"
  platform = "javascript"
  resolve_age = 760

  # Required if sentry_project_slug is null
  sentry_teams = ["developers"]
}


### Providers
terraform {
  required_providers {
    sentry = {
      source = "jianyuan/sentry"
      version = "~> 0.11"
    }
  }
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region  = local.region
  profile = "crossboard" # based on the AWS account
}

# Ignore the error below,
# Use resource specific `account_id` attributes instead.
# https://github.com/cloudflare/terraform-provider-cloudflare/issues/1711
provider "cloudflare" {}


# export SENTRY_AUTH_TOKEN=
provider "sentry" {}
```
