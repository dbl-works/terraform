output "app_secrets_arn" {
  value = [for secret in module.secrets : secret.arn]
}

output "app_secrets-kms-key" {
  value = [for kms in module.secrets-kms-key : kms.arn]
}

output "cloudflare_validation_hostnames" {
  value = [for record in cloudflare_record.validation : record.hostname]
}

output "aws_acm_certificate_arn" {
  value = [for certificate in aws_acm_certificate.main : certificate.arn]
}
