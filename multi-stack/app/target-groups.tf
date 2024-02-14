# Main entrypoint for the cluster applications
resource "aws_alb_target_group" "ecs" {
  for_each = var.project_settings

  name        = "${each.key}-${var.environment}-ecs"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.id
  target_type = "ip"

  health_check {
    path                = each.value.health_check_path
    healthy_threshold   = each.value.health_check_options.healthy_threshold
    unhealthy_threshold = each.value.health_check_options.unhealthy_threshold
    timeout             = each.value.health_check_options.timeout
    interval            = each.value.health_check_options.interval
    matcher             = each.value.health_check_options.matcher
    protocol            = each.value.health_check_options.protocol
  }

  tags = {
    Project     = each.key
    Environment = var.environment
  }
}
