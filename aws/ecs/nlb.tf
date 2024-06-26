resource "aws_lb" "nlb" {
  count              = length(var.allowlisted_ssh_ips) > 0 ? 1 : 0
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
  count       = length(aws_lb.nlb)
  name        = "${local.name}-ssh"
  port        = 22
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "ssh" {
  count             = length(aws_lb.nlb)
  load_balancer_arn = aws_lb.nlb[count.index].id
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.ssh[count.index].arn
    type             = "forward"
  }
}
