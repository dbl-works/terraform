output "endpoint" {
  description = "The endpoint of the primary node in this node group (shard)"
  value       = var.cluster_mode ? aws_elasticache_replication_group.cluster_mode[*].primary_endpoint_address : aws_elasticache_replication_group.non_cluster_mode[*].primary_endpoint_address
}

output "cluster_name" {
  value = local.cluster_name
}
