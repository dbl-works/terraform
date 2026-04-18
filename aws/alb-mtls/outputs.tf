output "trust_store_arn" {
  description = "ARN of the ALB Trust Store."
  value       = aws_lb_trust_store.main.arn
}

output "trust_store_name" {
  description = "Name of the ALB Trust Store."
  value       = aws_lb_trust_store.main.name
}
