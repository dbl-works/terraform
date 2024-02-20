# Load balancer endpoints for DNS values
output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "nlb_dns_name" {
  value = length(aws_lb.nlb) > 0 ? aws_lb.nlb[0].dns_name : null
}

# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = aws_alb_target_group.ecs.arn
}

output "nlb_target_group_ecs_arn" {
  value = length(aws_lb.nlb) > 0 ? aws_lb_target_group.ssh[0].arn : null
}

# Security groups, for linking with other resources
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

# Needed to attach additional ressources (e.g. certificates) to the ALB
output "https_alb_listener_arn" {
  value = aws_alb_listener.https.arn
}

# Need this for the usage of cloudwatch metrics
output "alb_arn_suffix" {
  value = aws_alb.alb.arn_suffix
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_discovery_namespace_id" {
  value = var.service_discovery_enabled ? aws_service_discovery_private_dns_namespace.main[0].id : "Service discovery not enabled."
}
