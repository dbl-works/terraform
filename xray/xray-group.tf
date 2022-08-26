resource "aws_xray_group" "error" {
  group_name        = "error"
  filter_expression = "error = true OR fault = true"

  insights_configuration {
    insights_enabled      = true
    notifications_enabled = true
  }
}

resource "aws_xray_group" "slow_response_time" {
  group_name        = "slow-response-time"
  filter_expression = "responsetime > ${var.response_time_threshold}"

  insights_configuration {
    insights_enabled      = true
    notifications_enabled = true
  }
}

resource "aws_xray_group" "long_duration" {
  group_name        = "long-duration"
  filter_expression = "duration > ${var.duration_threshold}"

  insights_configuration {
    insights_enabled      = true
    notifications_enabled = true
  }
}
