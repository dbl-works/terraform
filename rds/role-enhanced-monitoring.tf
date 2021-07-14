# RDS Enhanced Monitoring requires a specific role + KMS key to operate
resource "aws_iam_role" "rds-enhanced-monitoring" {
  name               = "rds-enhanced-monitoring-${var.project}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds-enhanced-monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}
