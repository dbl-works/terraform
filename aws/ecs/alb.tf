# Main load balancer for user facing traffic
resource "aws_alb" "alb" {
  name = local.name

  # At least two subnets in two different Availability Zones must be specified
  subnets = var.alb_subnet_ids

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

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
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
  for_each = { for idx, rule in var.alb_listener_rules : idx => rule }

  listener_arn = aws_alb_listener.https.arn
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

# WAF
resource "aws_wafv2_web_acl_association" "alb_waf" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_alb.alb.arn
  web_acl_arn  = var.waf_acl_arn == "default-web-acl" ? aws_wafv2_web_acl.default-web-acl[0].arn : var.waf_acl_arn
}
