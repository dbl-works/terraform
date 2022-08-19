output "database_url" {
  value = module.rds.database_url
}

output "database_arn" {
  value = module.rds.database_arn
}

output "redis_url" {
  value = module.elasticache.endpoint
}

output "vpc_id" {
  value = module.vpc.id
}

# Security groups and route tables, for linking with other resources
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

output "nat_route_table_ids" {
  value = module.nat.aws_route_table_ids
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
  value = var.rds_is_read_replica ? join("", module.vpc-peering.*.accept_status-requester) : "VPC peering not enabled."
}

output "accept_status-accepter" {
  value = var.rds_is_read_replica ? join("", module.vpc-peering.*.accept_status-accepter) : "VPC peering not enabled."
}

output "rds_kms_key_arn" {
  value = var.rds_master_db_kms_key_arn == null ? join("", module.rds-kms-key.*.arn) : "KMS ARN only printed for the master DB to be passed to each replica."
}

output "ecs_role_name" {
  value       = module.ecs.ecs_role_name
  description = "ECS container instance IAM role. Attach policy for container instances to this role to add permissions for future features and enhancements as they are introduce."
}
