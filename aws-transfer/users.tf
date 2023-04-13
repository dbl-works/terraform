data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "aws-transfer-family-roles-for-${var.project}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "AllowAccessToS3"
    effect = "Allow"
    actions = [
      # "s3:DeleteObject",
      # "s3:DeleteObjectVersion",
      # "s3:GetObject",
      # "s3:GetObjectVersion",
      # "s3:ListBucket",
      # "s3:ListBucketVersions",
      # "s3:ListObjectVersions",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:PutObjectVersionAcl",
    ]

    resources = [
      var.s3_prefix == null ? "${module.s3-storage.arn}/*" : "${module.s3-storage.arn}/${var.s3_prefix}*"
    ]
  }
}

resource "aws_iam_role_policy" "main" {
  name   = "aws-transfer-user-for-${var.project}-${var.environment}"
  role   = aws_iam_role.main.id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_transfer_user" "main" {
  for_each  = var.users
  server_id = aws_transfer_server.main.id
  user_name = each.key
  role      = aws_iam_role.main.arn

  home_directory = "/${var.s3_bucket_name}"

  tags = {
    Name        = each.key
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_transfer_ssh_key" "main" {
  for_each = var.users

  server_id = aws_transfer_server.main.id
  user_name = each.key
  body      = each.value["ssh_key"]
}
