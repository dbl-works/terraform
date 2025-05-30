resource "aws_security_group" "redshift" {
  name        = "${local.name}-redshift"
  description = "Security group for Redshift Serverless ${local.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name}-redshift"
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Allow inbound connections from ECS tasks on Redshift port
# This enables applications running in ECS to connect to Redshift for analytics queries
resource "aws_security_group_rule" "redshift_from_ecs" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redshift.id
  source_security_group_id = var.ecs_security_group_id
  description              = "Redshift access from ECS tasks"
}

# Allow inbound connections from RDS security group for zero-ETL integration
# This enables the managed zero-ETL service to replicate data from RDS to Redshift
resource "aws_security_group_rule" "redshift_from_rds" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redshift.id
  source_security_group_id = var.source_rds_security_group_id
  description              = "Redshift access from RDS for zero-ETL integration"
}

# Allow all outbound traffic
# Redshift may need to communicate with AWS services for management and data operations
resource "aws_security_group_rule" "redshift_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.redshift.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound traffic"
}
