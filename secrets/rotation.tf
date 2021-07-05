resource "aws_secretsmanager_secret_rotation" "main" {
  count = var.rotation_enabled ? 1 : 0

  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = aws_lambda_function.main.arn

  rotation_rules {
    automatically_after_days = var.rotate_automatically_after_days
  }
}

# to be done: implement a lambda to trigger rotation. See the docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
