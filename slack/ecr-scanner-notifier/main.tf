module "lambda" {
  source = "../lambda"

  function_name = "ecr-scanner-notifier-${var.project}-${var.environment}"
  project       = var.project
  environment   = var.environment
  source_dir    = "./script"

  environment_variables = {
    WEBHOOK_URL = var.slack_webhook_url
    CHANNEL     = var.slack_channel
  }

  # optional
  handler               = "lambda.lambda_handler"
  aws_lambda_layer_arns = []
}


# EventBridge was formerly known as CloudWatch Events. The functionality is identical.
resource "aws_cloudwatch_event_rule" "console" {
  name        = "ecr-scanner-${var.project}-${var.environment}"
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

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "ecr-scanner-${var.project}-${var.environment}" # The unique target assignment ID. If missing, will generate a random, unique id.
  arn       = module.lambda.lambda_arn
}
