resource "aws_redshiftserverless_namespace" "main" {
  namespace_name      = "${var.project}-${var.environment}"
  admin_username      = "admin"
  admin_user_password = local.infra_credentials.redshift_root_password
  db_name             = replace("${var.project}_${var.environment}", "/[^0-9A-Za-z_]/", "_")

  # IAM role for Redshift to access other AWS services (for zero-ETL integration)
  default_iam_role_arn = aws_iam_role.redshift_serverless_default.arn

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

# Default IAM role for the Redshift Serverless namespace
# This role is used by Redshift to access other AWS services like S3, RDS, etc.
resource "aws_iam_role" "redshift_serverless_default" {
  name = "${var.project}-${var.environment}-redshift-serverless-default"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift-serverless.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-redshift-serverless-default"
    Project     = var.project
    Environment = var.environment
  }
}
