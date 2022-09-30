output "lambda_role_arn" {
  value = var.lambda_role_arn == null ? aws_iam_role.lambda[0].arn : var.lambda_role_arn
}
