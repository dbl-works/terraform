locals {
  cloudwatch_event_rule_name = "${var.project}-${var.environment}-stopped_container"
}

resource "aws_cloudwatch_event_rule" "stopped_container" {
  name        = local.cloudwatch_event_rule_name
  description = "Capture stopped ECS container"

  event_pattern = jsonencode({
    source = ["aws.ecs"],
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwet2.html
    detail = {
      "clusterArn" = [aws_ecs_cluster.main.arn],
      "group"      = var.monitored_service_groups,
      "lastStatus" = [
        "STOPPED"
      ],
    }
    detail-type = [
      "ECS Task State Change"
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }

  depends_on = [
    aws_cloudwatch_log_group.stopped_container
  ]
}

resource "aws_cloudwatch_event_target" "stopped_container" {
  rule      = aws_cloudwatch_event_rule.stopped_container.name
  target_id = local.cloudwatch_event_rule_name
  arn       = aws_cloudwatch_log_group.stopped_container.arn
}

resource "aws_cloudwatch_log_group" "stopped_container" {
  name              = "/aws/events/${local.cloudwatch_event_rule_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
