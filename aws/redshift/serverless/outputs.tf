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

output "namespace_arn" {
  description = "ARN of the Redshift Serverless namespace"
  value       = aws_redshiftserverless_namespace.main.arn
}

output "workgroup_arn" {
  description = "ARN of the Redshift Serverless workgroup"
  value       = aws_redshiftserverless_workgroup.main.arn
}
