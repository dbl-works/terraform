# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#endpoint
output "database_url" {
  value = aws_db_instance.main.endpoint
}

output "database_arn" {
  value = aws_db_instance.main.arn
}
