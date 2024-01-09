output "ecs" {
  value = values(module.ecs)[*]
}

output "rds" {
  value = module.rds
}

output "elasticache" {
  value = module.elasticache
}

output "vpc" {
  value = module.vpc
}
