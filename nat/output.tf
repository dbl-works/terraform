output "aws_route_ids" {
  value = values(aws_route.main)[*].id
}
