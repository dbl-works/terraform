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
