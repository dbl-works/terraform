# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = module.ecs.alb_target_group_ecs_arn
}
