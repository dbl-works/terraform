# Terraform Module: Slack Notifier for Sentry isseus

Sending message to Slack when there is new sentry issues


## Usage

```terraform
module "sentry_slack_alert" {
  source = "github.com/dbl-works/terraform//aws/slack/sentry?ref=main"

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
# You will need to configure the provider by providing an authentication token. You can create an authentication token within Sentry by creating an internal integration. This is also available for self-hosted Sentry.
# It's best practice not to store the authentication token in plain text. As an alternative, the provider can source the authentication token from the SENTRY_AUTH_TOKEN environment variable. If you choose to do this, you can omit the token variable from the configuration block above.
# https://docs.sentry.io/product/integrations/integration-platform/internal-integration/#auth-tokens

# export SENTRY_AUTH_TOKEN=
provider "sentry" {}

# OR

provider "sentry" {
  token = "my-auth-token"
}
```
