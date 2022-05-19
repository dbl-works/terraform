# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#attributes-reference

output "id" {
  description = "AWS secrets manager resources ID"
  value       = aws_secretsmanager_secret.main.id
}

output "arn" {
  description = "AWS secrets manager AWS resources name"
  value       = aws_secretsmanager_secret.main.arn
}
