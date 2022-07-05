output "database_url" {
  value = module.rds.database_url
}

output "database_arn" {
  value = module.rds.database_arn
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


# When launching a stack with a read replica
output "accept_status-requester" {
  value = var.rds_is_read_replica ? module.vpc-peering.accept_status-requester : "VPC peering not enabled."
}

output "accept_status-accepter" {
  value = var.rds_is_read_replica ? module.vpc-peering.accept_status-accepter : "VPC peering not enabled."
}

output "rds_kms_key_arn" {
  value = var.rds_master_db_kms_key_arn == null ? module.rds-kms-key[0].arn : "KMS ARN only printed for the master DB to be passed to each replica."
}
