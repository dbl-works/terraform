# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#attributes-reference

output "secrets_arn" {
  value       = aws_secretsmanager_secret.main.arn
  description = "ARN of the ${var.outputoutput} secrets. Rotation is disabled."
}
