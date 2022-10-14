# "Action": "xray:Get*"
locals {
  # NOTE: no "environment" here since X-Ray is to be enabled once per region, regardless of app or environment
  name = var.name != null ? var.name : "${var.region}-xray"
}

# Readonly access to analytics
resource "aws_iam_group" "xray-view" {
  name = "${local.name}-view"
}
resource "aws_iam_policy" "xray-view" {
  name        = "${local.name}-view"
  path        = "/"
  description = "Allow connecting read-only permissions to X-Ray in region ${var.region} using IAM roles"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "xray:Get*"
      ],
      "Resource": [
        "arn:aws:xray:${var.region}:${var.account_id}:*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "xray-view" {
  group      = aws_iam_group.xray-view.name
  policy_arn = aws_iam_policy.xray-view.arn
}
