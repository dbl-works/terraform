output "lambda_log_group_name" {
  value = "/aws/lambda/${local.function_name}"
}
