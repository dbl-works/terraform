output "app_secrets_arn" {
  value = module.secrets["app"].arn
}

output "terraform_secrets_arn" {
  value = module.secrets["terraform"].arn
}
