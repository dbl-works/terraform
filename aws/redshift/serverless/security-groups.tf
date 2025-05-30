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

# Note: No egress rules defined
# Redshift Serverless is a fully managed service where AWS handles service-to-service
# communication through their managed infrastructure. Explicit egress rules are not
# required for normal operation including zero-ETL integration.
