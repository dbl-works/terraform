output "aws_route_ids" {
  value = aws_route.main[*].id
}
