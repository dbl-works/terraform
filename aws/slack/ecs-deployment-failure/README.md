# Terraform Module: Slack message for ECS Deployment Failure

Post a message to Slack when a deployment to AWS ECS has failed. The ECS Service needs to enable the [deployment circuit breaker](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-circuit-breaker.html) in order to trigger the slack message.

## Usage

```terraform
module "ecs_deployment_failure" {
  source = "github.com/dbl-works/terraform//slack/ecs-deployment-failure"

  project     = local.project
  environment = local.environment

  slack_webhook_url = "https://hooks.slack.com/services/x/y/z"

  # Optional
  runtime = "ruby2.7" # Ruby 3.2 requires Terraform version 5, but some modules aren't ready for Terraform v5 yet (e.g. S3)
  timeout = 10 # timeout for lambda function
  memory_size = 128 # memory size for lambda function
}
```

## Setting up Slack Webhook

Refer: https://api.slack.com/messaging/webhooks

1. Navigate to the Slack API
2. Create an App
3. After creating, select the Incoming Webhooks feature, and click Activate Incoming Webhooks toggle
4. Choose Add New Webhook to Workspace and select the channel which you want to send the message to
5. Copy the Webhook URL and use it as `slack_webhook_url`
