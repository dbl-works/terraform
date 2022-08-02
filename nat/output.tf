output "aws_route_table_ids" {
  value = aws_route_table.main[*].id
}
