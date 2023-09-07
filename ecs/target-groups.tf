# Main entrypoint for the cluster applications
resource "aws_alb_target_group" "ecs" {
  name        = "${local.name}-ecs"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2  # The number of consecutive health checks successes required before considering an unhealthy target healthy.
    unhealthy_threshold = 5  # The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold.
    timeout             = 30 # The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds.
    interval            = 60 # The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds.
    matcher             = "200,204"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
