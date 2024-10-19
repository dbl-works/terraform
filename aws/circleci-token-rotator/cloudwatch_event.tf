resource "aws_cloudwatch_event_rule" "rotate_circleci_token" {
  name                = local.name
  description         = "Rotate CircleCI Token every ${var.token_rotation_interval_days} days"
  schedule_expression = "rate(${var.token_rotation_interval_days} days)"

  tags = {
    Project = var.project
  }

  depends_on = [
    aws_cloudwatch_log_group.rotate_circleci_token
  ]
}

resource "aws_cloudwatch_log_group" "rotate_circleci_token" {
  name              = "/aws/events/${local.name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Project = var.project
  }
}

resource "aws_cloudwatch_event_target" "rotate_circleci_token" {
  rule      = aws_cloudwatch_event_rule.rotate_circleci_token.name
  target_id = local.name
  arn       = module.lambda.arn

  depends_on = [
    aws_cloudwatch_event_rule.rotate_circleci_token
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch_event_to_invoke_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = local.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rotate_circleci_token.arn

  depends_on = [
    module.lambda
  ]
}
