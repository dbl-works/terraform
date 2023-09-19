resource "aws_security_group" "main" {
  name   = "${var.project}-${var.environment}-httpproxy"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
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
  description       = "For the application to connect to the proxy"
}

# required to SSH into the machine to configure it or perform maintenance work
resource "aws_security_group_rule" "ingress-tcp-22-public" {
  count = var.maintenance_mode ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
  description       = "For maintenance mode to allow SSH access"
}

# required to e.g. download updates or install packages
resource "aws_security_group_rule" "egress-public-internet" {
  count = var.maintenance_mode ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
  description       = "For maintenance mode to allow access to the public internet"
}
