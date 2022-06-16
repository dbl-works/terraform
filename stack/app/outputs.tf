output "database_url" {
  value = module.rds.database_url
}

output "redis_url" {
  value = module.elasticache.endpoint
}

# pass this to the cloudflare module
output "domain_validation_information" {
  value       = module.certificate.domain_validation_information
  description = "Used to complete certificate validation, e.g. in Cloudflare."
}
