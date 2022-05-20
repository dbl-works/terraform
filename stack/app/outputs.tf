output "DATABASE_URL" {
  value = module.rds.database_url
}

output "REDIS_URL" {
  value = module.elasticache.endpoint
}
