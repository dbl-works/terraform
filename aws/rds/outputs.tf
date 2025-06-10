# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#endpoint
output "database_url" {
  value = aws_db_instance.main.endpoint
}

output "database_address" {
  value = aws_db_instance.main.address
}

output "database_arn" {
  value = aws_db_instance.main.arn
}

output "database_identifier" {
  value = aws_db_instance.main.identifier
}

output "database_security_group_id" {
  value = aws_security_group.db.id
}
