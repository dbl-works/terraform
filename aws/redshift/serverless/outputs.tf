output "endpoint" {
  description = "Redshift Serverless endpoint for connections"
  value       = aws_redshiftserverless_workgroup.main.endpoint[0].address
}

output "database_name" {
  description = "Name of the database"
  value       = aws_redshiftserverless_namespace.main.db_name
}

output "admin_username" {
  description = "Admin username for password authentication"
  value       = aws_redshiftserverless_namespace.main.admin_username
}

output "connection_url" {
  description = "PostgreSQL-compatible connection URL for Redshift Serverless (for use with pg gem and similar PostgreSQL drivers - copy this to your app secrets as REDSHIFT_CONNECTION_URL)"
  value       = "postgresql://${aws_redshiftserverless_namespace.main.admin_username}:${local.infra_credentials.redshift_root_password}@${aws_redshiftserverless_workgroup.main.endpoint[0].address}:5439/${aws_redshiftserverless_namespace.main.db_name}"
  sensitive   = true
}

output "jdbc_url" {
  description = "JDBC URL for Redshift Serverless (for native Redshift drivers)"
  value       = "jdbc:redshift://${aws_redshiftserverless_workgroup.main.endpoint[0].address}:5439/${aws_redshiftserverless_namespace.main.db_name}"
  sensitive   = false
}

output "namespace_arn" {
  description = "ARN of the Redshift Serverless namespace"
  value       = aws_redshiftserverless_namespace.main.arn
}

output "workgroup_arn" {
  description = "ARN of the Redshift Serverless workgroup"
  value       = aws_redshiftserverless_workgroup.main.arn
}
