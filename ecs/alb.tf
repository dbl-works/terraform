# Main load balancer for user facing traffic
resource "aws_alb" "alb" {
  name    = local.name
  subnets = var.subnet_public_ids
  security_groups = [
    aws_security_group.alb.id,
  ]
  enable_http2 = "true"
  idle_timeout = 600
  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.id
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
  load_balancer_arn = aws_alb.alb.id
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
  for_each = { for cert in var.additional_certificate_arns : cert.name => cert }

  listener_arn    = aws_alb_listener.https.arn
  certificate_arn = each.value.arn
}

resource "aws_lb_listener_rule" "main" {
  count = length(var.alb_listener_rule)

  listener_arn = aws_alb_listener.https.arn
  priority     = var.alb_listener_rule[count.index].priority

  action {
    type             = var.alb_listener_rule[count.index].type
    target_group_arn = var.alb_listener_rule[count.index].target_group_arn
  }

  dynamic "condition" {
    for_each = [var.alb_listener_rule[count.index].path_pattern]

    content {
      path_pattern {
        values = condition.value
      }
    }
  }
}
