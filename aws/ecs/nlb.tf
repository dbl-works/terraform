locals {
  create_nlb = length(var.allowlisted_ssh_ips) > 0
  nlb_count  = local.create_nlb ? 1 : 0
  nlb_keys   = local.create_nlb ? ["0"] : []
}

resource "aws_lb" "nlb" {
  for_each           = toset(local.nlb_keys)
  name               = "${local.name}-nlb"
  load_balancer_type = "network"
  # The NLB is configured for single-region deployment as it serves developer-only purposes, and we accept the associated downtime risks.
  subnets      = var.nlb_subnet_ids
  idle_timeout = var.keep_alive_timeout
  tags = {
    Name        = "${local.name}-nlb"
    Project     = var.project
    Environment = var.environment
  }
}

# Bastion is allowed, only from some IPs
resource "aws_lb_target_group" "ssh" {
  for_each    = toset(local.nlb_keys)
  name        = "${local.name}-ssh"
  port        = 22
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "ssh" {
  for_each          = toset(local.nlb_keys)
  load_balancer_arn = aws_lb.nlb[each.key].id
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.ssh[each.key].arn
    type             = "forward"
  }
}
