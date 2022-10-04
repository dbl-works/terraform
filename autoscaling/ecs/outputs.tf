output "ecs_autoscale_role_arn" {
  value = var.ecs_autoscale_role_arn == null ? aws_iam_role.ecs-autoscale-role[0].arn : var.ecs_autoscale_role_arn
}
