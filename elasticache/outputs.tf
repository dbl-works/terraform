output "endpoint" {
  description = "The endpoint of the primary node in this node group (shard)"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}
