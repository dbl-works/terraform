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
  name               = "aws-transfer-family-roles-for-${var.username}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.id
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_iam_policy" "main" {
  name   = "aws-transfer-family-s3-policy-for-${var.username}-using-${var.s3_bucket_name}"
  policy = data.aws_iam_policy_document.s3.json
}

locals {
  accessible_s3_path = var.s3_prefix == null ? var.s3_bucket_name : "${var.s3_bucket_name}/${var.s3_prefix}"
  s3_arn             = "arn:aws:s3:::${local.accessible_s3_path}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "AllowAccessToS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListObjectVersions",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:PutObjectVersionAcl",
    ]
    resources = [
      local.s3_arn,
      "${local.s3_arn}/*"
    ]
  }

  statement {
    sid    = "AllowAccessToKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
    ]
    resources = [
      var.s3_kms_arn
    ]
  }
}
