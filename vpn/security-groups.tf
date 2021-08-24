resource "aws_security_group" "main" {
  name   = "${var.project}-${var.environment}-vpn"
  vpc_id = module.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0", # TODO: Lock this down post-launch?
  ]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "outline" {
  type      = "ingress"
  from_port = 1024
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.main.id
}
