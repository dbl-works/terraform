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
  name               = "aws-transfer-family-roles-for-${var.project}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.id
  policy_arn = module.s3-storage.policy_arn
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
    resources = var.s3_prefix == null ?
      [
        "${module.s3-storage.arn}" :
        "${module.s3-storage.arn}/*" :
      ] : [
        "${module.s3-storage.arn}/${var.s3_prefix}"
        "${module.s3-storage.arn}/${var.s3_prefix}/*"
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
      "arn:aws:kms:eu-central-1:450135850488:key/21fd46fc-ec37-45f1-b59e-f65caf420818",
    ]
  }
}
