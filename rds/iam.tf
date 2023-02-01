locals {
  db_roles = [
    "admin",
    "readonly",
  ]
}

# Readonly access to database
# We allow `ListPolicies` to allow filtering all describable instances by those we can connect to
resource "aws_iam_group" "rds-db-connect" {
  for_each = toset(local.db_roles)
  name     = "${local.name}-rds-db-connect-${each.key}"
}
resource "aws_iam_policy" "rds-db-connect" {
  for_each    = toset(local.db_roles)
  name        = "${local.name}-rds-db-connect-${each.key}"
  path        = "/"
  description = "Allow connecting as ${each.key} to ${var.project} ${var.environment} (${var.region}) using IAM roles"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": [
        "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${aws_db_instance.main.resource_id}/${var.project}_${var.environment}_${each.key}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListPolicies"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:policy/${local.name}-rds-db-connect-*",
        "arn:aws:iam::${var.account_id}:policy/${local.name}-rds-view"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "rds-db-connect" {
  for_each   = toset(local.db_roles)
  group      = aws_iam_group.rds-db-connect[each.key].name
  policy_arn = aws_iam_policy.rds-db-connect[each.key].arn
}



# Grant access to list and describe instances
resource "aws_iam_group" "rds-view" {
  name = "${local.name}-rds-view"
}
resource "aws_iam_policy" "rds-view" {
  name        = "${local.name}-rds-view"
  path        = "/"
  description = "Allow viewing db instances for ${var.project} ${var.environment}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:Describe*",
        "rds:Get*",
        "rds:List*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "${var.project}",
          "aws:ResourceTag/Environment": "${var.environment}"
        }
      },
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "rds-view" {
  group      = aws_iam_group.rds-view.name
  policy_arn = aws_iam_policy.rds-view.arn
}
