resource "aws_kms_key_policy" "main" {
  key_id = module.s3-cloudtrail.kms-key-id
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

data "aws_caller_identity" "current" {}

# https://repost.aws/questions/QUWhCJrwGnT5qh-LUpFlxfpw/kms-policy-for-cross-account-cloudtrail
data "aws_iam_policy_document" "kms_key_policy" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail service to encrypt/decrypt"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = flatten([for account_id in var.logging_account_ids : ["arn:aws:iam::${account_id}:root"]])
    }

    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = flatten([for account_id in var.logging_account_ids : ["arn:aws:iam::${account_id}:root"]])
    }

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = flatten([for account_id in var.logging_account_ids : ["arn:aws:cloudtrail:*:${account_id}:trail/*"]])
    }
  }
}
