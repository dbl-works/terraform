locals {
  function_name = "${var.project}-ecr-scanner-notifier"
}
module "lambda" {
  source = "../../lambda"

  function_name = local.function_name
  project       = var.project
  environment   = "production"
  source_dir    = "${path.module}/script"

  environment_variables = {
    WEBHOOK_URL = var.slack_webhook_url
    CHANNEL     = var.slack_channel
  }

  # optional
  handler               = "main.lambda_handler"
  aws_lambda_layer_arns = []
  runtime               = "ruby3.2"
}

# EventBridge was formerly known as CloudWatch Events. The functionality is identical.
resource "aws_cloudwatch_event_rule" "ecr_scanner" {
  name        = "${var.project}-ecr-scanner"
  description = "Send notification to slack after each ecr scan"

  event_pattern = <<EOF
{
  "source": ["aws.ecr"],
  "detail-type": ["ECR Image Scan"],
  "detail": {
    "finding-severity-counts": {
      "$or": [{
        "CRITICAL": [{
          "exists": true
        }]
      }, {
        "HIGH": [{
          "exists": true
        }]
      }, {
        "MEDIUM": [{
          "exists": true
        }]
      }, {
        "LOW": [{
          "exists": true
        }]
      }, {
        "UNDEFINED": [{
          "exists": true
        }]
      }]
    }
  }
}
  EOF

  tags = {
    Project = var.project
  }
}

resource "aws_cloudwatch_event_target" "ecr_scanner" {
  rule      = aws_cloudwatch_event_rule.ecr_scanner.name
  target_id = aws_cloudwatch_event_rule.ecr_scanner.name
  arn       = module.lambda.arn

  depends_on = [
    aws_cloudwatch_event_rule.ecr_scanner
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch_event_to_invoke_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_scanner.arn

  depends_on = [
    module.lambda
  ]
}
