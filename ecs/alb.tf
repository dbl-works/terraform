# Main load balancer for user facing traffic
resource "aws_alb" "alb" {
  count = var.skip_load_balancer ? 0 : 1

  name = local.name

  # At least two subnets in two different Availability Zones must be specified
  subnets = slice(var.subnet_public_ids, 0, 2)

  security_groups = [
    aws_security_group.alb.id,
  ]
  enable_http2 = "true"
  idle_timeout = var.keep_alive_timeout # The time in seconds that the connection is allowed to be idle.
  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_alb_listener" "http" {
  count = var.skip_load_balancer ? 0 : 1

  load_balancer_arn = aws_alb.alb[0].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  count = var.skip_load_balancer ? 0 : 1

  load_balancer_arn = aws_alb.alb[0].id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.ecs.arn
    type             = "forward"
  }
}

# Using SNI to attach multiple certificates to the same load balancer
resource "aws_alb_listener_certificate" "https" {
  for_each = { for idx, arn in var.additional_certificate_arns : idx => arn }

  listener_arn    = aws_alb_listener.https[0].arn
  certificate_arn = each.value
}

resource "aws_lb_listener_rule" "main" {
  for_each = { for idx, rule in var.alb_listener_rules : idx => rule }

  listener_arn = aws_alb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = each.value.type
    target_group_arn = each.value.target_group_arn
  }

  dynamic "condition" {
    for_each = length(each.value.path_pattern) > 0 ? [1] : []
    content {
      path_pattern {
        values = each.value.path_pattern
      }
    }
  }

  dynamic "condition" {
    for_each = length(each.value.host_header) > 0 ? [1] : []
    content {
      host_header {
        values = each.value.host_header
      }
    }
  }
}
