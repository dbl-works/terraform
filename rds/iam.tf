locals {
  db_roles = [
    "admin",
    "readonly",
  ]
}

# Readonly access to system
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
