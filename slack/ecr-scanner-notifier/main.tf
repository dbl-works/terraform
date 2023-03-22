module "lambda" {
  source = "../../lambda"

  function_name = "ecr-scanner-notifier-${var.project}"
  project       = var.project
  environment   = "production"
  source_dir    = "${path.module}/script"

  environment_variables = {
    WEBHOOK_URL = var.slack_webhook_url
    CHANNEL     = var.slack_channel
  }

  # optional
  handler               = "lambda.lambda_handler"
  aws_lambda_layer_arns = []
  runtime               = var.runtime
}


# EventBridge was formerly known as CloudWatch Events. The functionality is identical.
resource "aws_cloudwatch_event_rule" "console" {
  name        = "ecr-scanner-${var.project}"
  description = "Send notification to slack after each ecr scan"

  event_pattern = jsonencode({
    detail-type = [
      "ECR Image Scan"
    ]
    source = [
      "aws.ecr"
    ]
  })
}

resource "aws_cloudwatch_event_target" "ecr-scanner" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "ecr-scanner-${var.project}" # The unique target assignment ID. If missing, will generate a random, unique id.
  arn       = module.lambda.lambda_arn
}
