resource "aws_security_group" "main" {
  name   = "${var.project}-${var.environment}-elasticache"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }

  # egress {
  #   from_port = 0
  #   to_port = 0
  #   protocol = -1
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

resource "aws_security_group_rule" "main" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.main.id
  cidr_blocks = [
    var.vpc_cidr,
  ]
}
