output "id" {
  description = "AWS VPC id"
  value       = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "subnet_public_ids" {
  value = aws_subnet.public.*.id
}

output "subnet_private_ids" {
  value = aws_subnet.private.*.id
}
