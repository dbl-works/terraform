#
# Allow passing through traffic via SSH, e.g. for:
#   * SSH tunneling to the database
#   * SSH tunneling to the ECS cluster ("console access")
#
resource "aws_lb_target_group" "ssh" {
  count = length(var.allowlisted_ssh_ips) > 0 ? 1 : 0

  name        = "${local.name}-ssh"
  port        = 22
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "ssh" {
  count = length(var.allowlisted_ssh_ips) > 0 ? 1 : 0

  load_balancer_arn = aws_alb.alb.id
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.ssh[count.index].arn
    type             = "forward"
  }
}
