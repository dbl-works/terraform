locals {
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }

  budget_name = var.budget_name != "" ? var.budget_name : "${var.project}-${var.environment}-budget"
}

# Per-project/environment budget, filtered by tags
resource "aws_budgets_budget" "main" {
  name              = local.budget_name
  budget_type       = var.budget_type
  limit_amount      = var.limit_amount
  limit_unit        = var.limit_unit
  time_unit         = var.time_unit
  time_period_start = var.time_period_start

  cost_filter {
    name = "TagKeyValue"
    values = [
      for key, value in local.default_tags : "user:${key}$${value}"
    ]
  }

  # Alert when actual spend exceeds threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.actual_threshold_percentage
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.subscriber_email_addresses
    subscriber_sns_topic_arns  = var.subscriber_sns_topic_arns
  }

  # Alert when forecasted spend exceeds threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.forecasted_threshold_percentage
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.subscriber_email_addresses
    subscriber_sns_topic_arns  = var.subscriber_sns_topic_arns
  }

  tags = local.default_tags
}

# Optional: global account-wide budget (no tag filtering)
resource "aws_budgets_budget" "account" {
  count = var.account_limit_amount != null ? 1 : 0

  name              = "${var.project}-${var.environment}-account-budget"
  budget_type       = var.budget_type
  limit_amount      = var.account_limit_amount
  limit_unit        = var.limit_unit
  time_unit         = var.time_unit
  time_period_start = var.time_period_start

  # Alert when actual spend exceeds threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.actual_threshold_percentage
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.subscriber_email_addresses
    subscriber_sns_topic_arns  = var.subscriber_sns_topic_arns
  }

  # Alert when forecasted spend exceeds threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.forecasted_threshold_percentage
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.subscriber_email_addresses
    subscriber_sns_topic_arns  = var.subscriber_sns_topic_arns
  }

  tags = local.default_tags
}
