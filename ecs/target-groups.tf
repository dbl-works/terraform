# Main entrypoint for the cluster applications
resource "aws_alb_target_group" "ecs" {
  name        = "${local.name}-ecs"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = var.health_check_options.healthy_threshold
    unhealthy_threshold = var.health_check_options.unhealthy_threshold
    timeout             = var.health_check_options.timeout
    interval            = var.health_check_options.interval
    matcher             = var.health_check_options.matcher
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
