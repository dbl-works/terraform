# Load balancer endpoints for DNS values
output "alb_dns_name" {
  value = aws_alb.alb[0].dns_name
}
output "nlb_dns_name" {
  value = aws_lb.nlb[0].dns_name
}

# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = aws_alb_target_group.ecs.arn
}

# Security groups, for linking with other resources
output "alb_security_group_id" {
  value = aws_security_group.alb[0].id
}
output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}
