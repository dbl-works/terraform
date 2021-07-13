resource "aws_lb" "nlb" {
  count              = length(var.allowlisted_ssh_ips) > 0 ? 1 : 0
  name               = "${local.name}-nlb"
  load_balancer_type = "network"
  subnets            = var.subnet_public_ids
  idle_timeout       = 600
  tags = {
    Name        = "${var.project}-${var.environment}-nlb"
    Project     = var.project
    Environment = var.environment
  }
}

# Bastion is allowed, only from some IPs
resource "aws_lb_target_group" "bastion" {
  count       = length(aws_lb.nlb)
  name        = "${var.project}-${var.environment}-bastion"
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
    target_group_arn = aws_lb_target_group.bastion[count.index].arn
    type             = "forward"
  }
}
