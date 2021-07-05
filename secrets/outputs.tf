# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#attributes-reference

output "secrets_id" {
  value = aws_secretsmanager_secret.main.id
}

output "secrets_arn" {
  value = aws_secretsmanager_secret.main.arn
}
