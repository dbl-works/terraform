# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#attributes-reference

output "id" {
  description = "AWS secrets manager resources ID"
  value       = aws_secretsmanager_secret.main.id
}

output "arn" {
  description = "AWS secrets manager AWS resources name"
  value       = aws_secretsmanager_secret.main.arn
}

output "kms_key_id" {
  description = "AWS secrets manager KMS key ID"
  value       = var.kms_key_id == null ? module.kms-key[0].id : var.kms_key_id
}

output "kms_key_arn" {
  description = "AWS secrets manager KMS key ARN"
  value       = var.kms_key_id == null ? module.kms-key[0].arn : null
}
