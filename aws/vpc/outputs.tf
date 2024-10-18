output "id" {
  description = "AWS VPC id"
  value       = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "subnet_public_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "subnet_private_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "route_table_ids" {
  value = [for route_table in aws_route_table.main : route_table]
}
