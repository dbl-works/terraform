# Terraform Module: AWS Budgets

A module to provision an AWS Budget to track cost and usage, filtered by `Project` and `Environment` tags.

Optionally, a global account-wide budget (without tag filtering) can be created by setting `account_limit_amount`.

## Usage

```terraform
module "budget" {
  source = "github.com/dbl-works/terraform//aws/budget?ref=main"

  project      = "someproject"
  environment  = "staging"
  limit_amount = "100" # default currency: EUR

  subscriber_email_addresses = ["alerts@example.com"]
}
```

### Advanced Usage

```terraform
module "budget" {
  source = "github.com/dbl-works/terraform//aws/budget?ref=main"

  project     = "someproject"
  environment = "production"

  # Per-project budget
  budget_name  = "custom-team-budget"
  limit_amount = "500.50"

  # Global account-wide budget (no tag filtering)
  account_limit_amount = "1000"

  subscriber_email_addresses      = ["alerts@example.com"]
  subscriber_sns_topic_arns       = ["arn:aws:sns:eu-west-1:1234567890:some-topic"]
  actual_threshold_percentage     = 80
  forecasted_threshold_percentage = 90
}
```
