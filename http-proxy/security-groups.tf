resource "aws_security_group" "main" {
  name   = "${var.project}-${var.environment}-httpproxy"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

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
