output "app_secrets_arn" {
  value = module.secrets["app"].arn
}

output "terraform_secrets_arn" {
  value = module.secrets["terraform"].arn
}

output "app_secrets-kms-key" {
  value = module.secrets-kms-key["app"].arn
}

output "terraform_secrets-kms-key" {
  value = module.secrets-kms-key["terraform"].arn
}

output "eips-nat" {
  value = [
    for eip in aws_eip.nat : eip.public_ip
  ]
}

output "kms-key-replica-rds-arn" {
  value = var.rds_cross_region_kms_key_arn == null ? "Not applicable if 'rds_cross_region_kms_key_arn' is not set." : join("", module.kms-key-replica-rds.*.arn)
}

output "cloudflare_validation_hostnames" {
  value = var.is_read_replica_on_same_domain ? [] : cloudflare_record.validation.*.hostname
}

output "aws_acm_certificate_arn" {
  value = var.is_read_replica_on_same_domain ? "" : aws_acm_certificate.main[0].arn
}
