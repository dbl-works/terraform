output "database_url" {
  value = module.rds.database_url
}

output "redis_url" {
  value = module.elasticache.endpoint
}
