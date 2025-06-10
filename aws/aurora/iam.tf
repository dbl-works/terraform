# Aurora Enhanced Monitoring requires a specific role + KMS key to operate
resource "aws_iam_role" "rds-enhanced-monitoring" {
  name               = "aurora-enhanced-monitoring-${local.name}"
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

# Database access IAM resources
data "aws_caller_identity" "current" {}

locals {
  db_roles = [
    "admin",
    "readonly",
  ]
  account_id = data.aws_caller_identity.current.account_id
}

# IAM groups for database connections
resource "aws_iam_group" "aurora-db-connect" {
  for_each = toset(local.db_roles)
  name     = "${local.name}-aurora-db-connect-${each.key}"
}

resource "aws_iam_policy" "aurora-db-connect" {
  for_each    = toset(local.db_roles)
  name        = "${local.name}-aurora-db-connect-${each.key}"
  path        = "/"
  description = "Allow connecting as ${each.key} to ${local.name} Aurora cluster (${var.region}) using IAM roles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${var.region}:${local.account_id}:dbuser:${aws_rds_cluster.main.cluster_resource_id}/${var.project}_${var.environment}_${each.key}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:ListPolicies"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:policy/${local.name}-aurora-db-connect-*",
          "arn:aws:iam::${local.account_id}:policy/${local.name}-aurora-view"
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "aurora-db-connect" {
  for_each   = toset(local.db_roles)
  group      = aws_iam_group.aurora-db-connect[each.key].name
  policy_arn = aws_iam_policy.aurora-db-connect[each.key].arn
}

# Grant access to list and describe Aurora clusters
resource "aws_iam_group" "aurora-view" {
  name = "${local.name}-aurora-view"
}

resource "aws_iam_policy" "aurora-view" {
  name        = "${local.name}-aurora-view"
  path        = "/"
  description = "Allow viewing Aurora clusters for ${local.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:Get*",
          "rds:List*"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project"     = var.project
            "aws:ResourceTag/Environment" = var.environment
          }
        }
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "aurora-view" {
  group      = aws_iam_group.aurora-view.name
  policy_arn = aws_iam_policy.aurora-view.arn
}
