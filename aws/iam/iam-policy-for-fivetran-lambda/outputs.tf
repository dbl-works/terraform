output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  value = aws_iam_role.lambda.name
}
