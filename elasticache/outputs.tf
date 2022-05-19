output "endpoint" {
  description = "Elasticache cluster cache node address"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}
