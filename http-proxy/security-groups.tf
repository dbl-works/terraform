resource "aws_security_group" "main" {
  name   = "${var.project}-${var.environment}-httpproxy"
  vpc_id = var.vpc_id

  #
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# this is required for the application to connect to the proxy
resource "aws_security_group_rule" "ingress-tcp-8888-vpc" {
  type              = "ingress"
  from_port         = 8888
  to_port           = 8888
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_block]
  security_group_id = aws_security_group.main.id
}

# enable this only for the configuration of the proxy
resource "aws_security_group_rule" "ingress-tcp-22-public" {
  count = var.ssh_enabled ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}
