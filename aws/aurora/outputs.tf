# Aurora Cluster outputs
output "cluster_arn" {
  value = aws_rds_cluster.main.arn
  description = "Aurora cluster ARN (use this for zero-ETL integration source_rds_arn)"
}

output "cluster_endpoint" {
  value = aws_rds_cluster.main.endpoint
  description = "Aurora cluster writer endpoint"
}

output "cluster_reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
  description = "Aurora cluster reader endpoint"
}

output "cluster_identifier" {
  value = aws_rds_cluster.main.cluster_identifier
  description = "Aurora cluster identifier"
}

output "cluster_members" {
  value = aws_rds_cluster.main.cluster_members
  description = "List of Aurora cluster members"
}

output "cluster_resource_id" {
  value = aws_rds_cluster.main.cluster_resource_id
  description = "Aurora cluster resource ID (used for IAM authentication)"
}

output "database_name" {
  value = aws_rds_cluster.main.database_name
  description = "Database name"
}

output "security_group_id" {
  value = aws_security_group.db.id
  description = "Security group ID for Aurora cluster"
}

# Compatibility outputs (for easier migration from RDS module)
output "database_url" {
  value = aws_rds_cluster.main.endpoint
  description = "Database endpoint URL (alias for cluster_endpoint)"
}

output "database_address" {
  value = aws_rds_cluster.main.endpoint
  description = "Database address (alias for cluster_endpoint)"
}

output "database_arn" {
  value = aws_rds_cluster.main.arn
  description = "Database ARN (alias for cluster_arn)"
}

output "database_identifier" {
  value = aws_rds_cluster.main.cluster_identifier
  description = "Database identifier (alias for cluster_identifier)"
}

output "database_security_group_id" {
  value = aws_security_group.db.id
  description = "Database security group ID (alias for security_group_id)"
}

# IAM outputs
output "iam_group_arns_db_connect" {
  value = { for role, group in aws_iam_group.aurora-db-connect : role => group.arn }
  description = "IAM group ARNs for database connections"
}

output "iam_group_arn_view" {
  value = aws_iam_group.aurora-view.arn
  description = "IAM group ARN for viewing Aurora clusters"
}
