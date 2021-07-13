# Main entrypoint for the cluster applications
resource "aws_alb_target_group" "ecs" {
  name        = "${var.project}-${var.environment}-ecs"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 25
    interval            = 30
    matcher             = "200,301,302,401,403,404"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
