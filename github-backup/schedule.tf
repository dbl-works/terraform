resource "aws_cloudwatch_event_rule" "main" {
  name                = local.name
  schedule_expression = "rate(${var.interval_value} ${var.interval_unit})"
}

resource "aws_cloudwatch_event_target" "main" {
  rule      = aws_cloudwatch_event_rule.main.name
  target_id = "${var.github_org}-${var.environment}-github-backup"
  arn       = module.lambda.arn
}
