resource "aws_security_group" "main" {
  name   = local.elasticache_name
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

# to avoid breaking changes for switching from "vpc_cidr" ( string ) to "allow_from_cidr_blocks" ( list )
locals {
  vpc_cidr_blocks = distinct(compact(flatten(
    [
      var.allow_from_cidr_blocks,
      var.vpc_cidr,
    ]
  )))
}

resource "aws_security_group_rule" "main" {
  count = length(local.vpc_cidr_blocks) # avoid creating any, if no CIDR blocks are passed

  description       = "From CIDR Block: ${local.vpc_cidr_blocks[count.index]}"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.main.id

  cidr_blocks = [
    local.vpc_cidr_blocks[count.index],
  ]
}
