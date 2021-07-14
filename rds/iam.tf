locals {
  db_roles = [
    "admin",
    "readonly",
  ]
}

# Readonly access to database
resource "aws_iam_group" "rds-db" {
  for_each = toset(local.db_roles)
  name     = "rds-db-${var.project}-${var.environment}-${each.key}"
}
resource "aws_iam_policy" "rds-db-connect" {
  for_each    = toset(local.db_roles)
  name        = "rds_db_${each.key}_connect_${var.project}_${var.environment}"
  path        = "/"
  description = "Allow connecting as ${each.key} to ${var.project} ${var.environment} using their IAM roles"

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
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "rds-db-connect" {
  for_each   = toset(local.db_roles)
  group      = aws_iam_group.rds-db[each.key].name
  policy_arn = aws_iam_policy.rds-db-connect[each.key].arn
}



# Grant access to list and describe instances
resource "aws_iam_group" "rds" {
  name     = "rds-${var.project}-${var.environment}"
}
resource "aws_iam_policy" "rds" {
  name        = "rds_${var.project}_${var.environment}"
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
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "rds" {
  for_each   = toset(local.db_roles)
  group      = aws_iam_group.rds[each.key].name
  policy_arn = aws_iam_policy.rds[each.key].arn
}
