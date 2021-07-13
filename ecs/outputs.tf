# Load balancer endpoints for DNS values
output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}
output "nlb_dns_name" {
  value = length(aws_lb.nlb) > 0 ? aws_lb.nlb[*].dns_name : null
}

# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = aws_alb_target_group.ecs.arn
}

# Security groups, for linking with other resources
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}
output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}
