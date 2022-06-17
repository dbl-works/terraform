output "endpoint" {
  description = "The endpoint of the primary node in this node group (shard)"
  value       = var.shard_count == 0 ? aws_elasticache_replication_group.non_cluster_mode[*].primary_endpoint_address : aws_elasticache_replication_group.cluster_mode[*].primary_endpoint_address
}
