resource "aws_cloudwatch_metric_alarm" "account_billing_alarm" {
  alarm_name          = "account-billing-alarm"
  alarm_description   = "Billing consolidated alarm >= USD ${var.monthly_billing_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = var.period_for_billing_alert # 8 hours
  statistic           = "Maximum"
  threshold           = var.monthly_billing_threshold
  alarm_actions       = [module.slack-sns.arn]
  datapoints_to_alarm = 1

  dimensions = {
    Currency = "USD"
  }
}

module "slack-sns" {
  providers = {
    aws = aws.us-east-1
  }

  source         = "../../slack/sns"
  sns_topic_name = var.sns_topic_name
}
