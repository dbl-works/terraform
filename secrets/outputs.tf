# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#attributes-reference

output "secrets_arn" {
  value       = aws_secretsmanager_secret.main.arn
  description = "ARN of the ${var.outputoutput} secrets."
}

output "secrets_rotation_enabled" {
  value       = aws_secretsmanager_secret_rotation.main[0].rotation_enabled
  description = "Rotation setting for ${var.outputoutput} secrets."
}
