output "database_url" {
  value = module.rds.database_url
}

output "redis_url" {
  value = module.elasticache.endpoint
}

# Security groups, for linking with other resources
output "alb_security_group_id" {
  value = module.ecs.alb_security_group_id
}
output "ecs_security_group_id" {
  value = module.ecs.ecs_security_group_id
}

output "subnet_public_ids" {
  value = module.vpc.subnet_public_ids
}

output "subnet_private_ids" {
  value = module.vpc.subnet_private_ids
}

# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = module.ecs.alb_target_group_ecs_arn
}
output "nlb_target_group_ecs_arn" {
  value = module.ecs.nlb_target_group_ecs_arn
}
