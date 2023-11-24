output "database_url" {
  value = var.skip_rds ? "" : module.rds[0].database_url
}

output "database_arn" {
  value = var.skip_rds ? "" : module.rds[0].database_arn
}

output "redis_url" {
  value = var.skip_elasticache ? [] : module.elasticache[0].endpoint
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
  value = (var.rds_master_db_kms_key_arn != null || var.skip_rds) ? "KMS ARN only printed for the master DB to be passed to each replica." : join("", module.rds-kms-key.*.arn)
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "alb_arn_suffix" {
  value = module.ecs.alb_arn_suffix
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "nlb_dns_name" {
  value = module.ecs.nlb_dns_name
}

# DNSSEC outputs a public key that must be added to AWS Route53
output "dnssec_instructions" {
  value = module.cloudflare[*].dnssec_instructions
}

output "dnssec_algorithm" {
  value = module.cloudflare[*].dnssec_algorithm
}

output "dnssec_key_type" {
  value = module.cloudflare[*].dnssec_key_type
}

output "dnssec_public_key" {
  value = module.cloudflare[*].dnssec_public_key
}

output "service_discovery_namespace_id" {
  value = module.ecs.service_discovery_namespace_id
}
