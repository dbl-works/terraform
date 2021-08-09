output "aws_cognito_identity_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "aws_cognito_identity_pool_arn" {
  value = aws_cognito_user_pool.pool.arn
}

output "aws_exports_content" {
  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cognito_identity_pool.main,
    aws_cognito_user_pool_client.client
  ]
  value = templatefile("${path.module}/aws-exports.ts.tmpl", {
    region : var.region,
    user_pool_id : aws_cognito_user_pool.pool.id,
    identity_pool_id : aws_cognito_identity_pool.main.id,
    user_pool_web_client_id : aws_cognito_user_pool_client.client.id,
  })
}
