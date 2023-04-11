resource "aws_security_group" "db" {
  name   = "${local.name}-db"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${local.name}-db"
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "db-from-cidr-blocks" {
  count             = length(var.allow_from_cidr_blocks)
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks = [
    var.allow_from_cidr_blocks[count.index],
  ]
  description = "From CIDR Block: ${var.allow_from_cidr_blocks[count.index]}"
}

resource "aws_security_group_rule" "db-from-security-groups" {
  count                    = length(var.allow_from_security_groups)
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.allow_from_security_groups[count.index]
  description              = "From security group: ${var.allow_from_security_groups[count.index]}"
}
