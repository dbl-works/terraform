resource "aws_cognito_user_pool_client" "client" {
  name = "${var.project}-${var.environment}"

  user_pool_id = aws_cognito_user_pool.pool.id
}
