resource "aws_cloudwatch_event_rule" "deployment" {
  name        = "deployment-failure"
  description = "Capture deployment failure"

  event_pattern = jsonencode({
    source = ["aws.ecs"],
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html#ecs_service_deployment_events
    # List of deployment event notifications
    detail-type = [
      "ECS Deployment State Change"
    ]
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.deployment.name
  target_id = "SendToLambda"
  arn       = module.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.deployment.arn

  depends_on = [
    module.lambda
  ]
}
