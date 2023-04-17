module "aws-transfer-iam-role" {
  source = "./iam-role"

  for_each = var.users

  username       = each.key
  s3_prefix      = each.value["s3_prefix"]
  s3_bucket_name = each.value["s3_bucket_name"] == null ? var.s3_bucket_name : each.value["s3_bucket_name"]
  s3_kms_arn     = each.value["s3_kms_arn"] == null ? module.s3-storage[0].kms-key-arn : each.value["s3_kms_arn"]
}

resource "aws_iam_role" "logging" {
  name = "aws-transfer-family-logging-role-for-${var.project}-${var.environment}"
}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.logging.id
  policy_arn = aws_iam_policy.logging.arn
}

resource "aws_iam_policy" "logging" {
  name = "aws-transfer-logging-policy-for-${var.project}-${var.environment}"

  policy = data.aws_iam_policy_document.logging.json
}

data "aws_iam_policy_document" "logging" {
  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/transfer/*"
    ]
  }
}
