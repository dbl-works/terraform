# Main load balancer for user facing traffic
resource "aws_alb" "alb" {
  name            = "${var.project}-${var.environment}"
  subnets         = module.vpc.subnet_public_ids
  security_groups = values(module.ecs).*.alb_security_group_id
  enable_http2    = "true"
  idle_timeout    = var.keep_alive_timeout # The time in seconds that the connection is allowed to be idle.
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

locals {
  default_project_name = keys(var.project_settings)[0]
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.default[local.default_project_name].arn

  default_action {
    target_group_arn = module.ecs[local.default_project_name].alb_target_group_ecs_arn
    type             = "forward"
  }
}

# Using SNI to attach multiple certificates to the same load balancer
resource "aws_alb_listener_certificate" "https" {
  for_each = { for cert in data.aws_acm_certificate.default : cert.arn => cert }

  listener_arn    = aws_alb_listener.https.arn
  certificate_arn = each.key
}

resource "aws_lb_listener_rule" "main" {
  for_each = {
    for idx, name in keys(var.project_settings) :
    idx => {
      name     = name
      settings = var.project_settings[name]
    }
  }

  listener_arn = aws_alb_listener.https.arn
  priority     = each.key + 1 # The priority for the rule between 1 and 50000.

  action {
    type             = "forward"
    target_group_arn = module.ecs[each.value.name].alb_target_group_ecs_arn
  }

  condition {
    host_header {
      values = [each.value.settings.domain]
    }
  }
}
