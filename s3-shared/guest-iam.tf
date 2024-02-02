resource "aws_iam_user" "guest" {
  name = "guest-${var.guest_account_name}"
  path = "/guest/"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:DeleteObject"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "s3" {
  name   = "s3-access-for-${module.s3.bucket_name}"
  user   = aws_iam_user.guest.name
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_group" "iam-guest-humans" {
  group_name = "guest-humans"
}

resource "aws_iam_user_group_membership" "memberships" {
  user   = aws_iam_user.guest.name
  groups = [data.aws_iam_group.iam-guest-humans.group_name]
}
