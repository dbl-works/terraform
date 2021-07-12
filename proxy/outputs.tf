# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = module.ecs.alb_target_group_ecs_arn
}

# Target groups, for use in deployments
output "ecs_security_group_id" {
  value = module.ecs.ecs_security_group_id
}

# @TODO: print out public subnets for proxy
# @TODO: print out ELB endpont for Cloudflare from proxy
# @TODO: print out secrets for proxy -> do we need them?
