output "aws_cognito_identity_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "aws_cognito_identity_pool_arn" {
  value = aws_cognito_user_pool.pool.arn
}

resource "local_file" "aws-exports" {
  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cognito_identity_pool.main,
    aws_cognito_user_pool_client.client
  ]

  filename = var.config_filename
  content = templatefile("${path.module}/../../modules/cognito/aws-exports.js.tmpl", {
    region : var.region,
    user_pool_id : aws_cognito_user_pool.pool.id,
    identity_pool_id : aws_cognito_identity_pool.main.id,
    user_pool_web_client_id : aws_cognito_user_pool_client.client.id,
  })
}
