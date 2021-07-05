# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#attributes-reference

output "id" {
  value = aws_secretsmanager_secret.main.id
}

output "arn" {
  value = aws_secretsmanager_secret.main.arn
}
