resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/lambda/${var.function_name}"
  retention_in_days = 90

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
