resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

data "aws_elb_service_account" "main" {}

locals {
  has_writers            = length(var.writers) > 0
  has_malware_policy     = var.file_malwarescanning.enabled
  has_bucket_policy      = local.has_writers || local.has_malware_policy
  block_infected_only    = var.file_malwarescanning.enabled && var.file_malwarescanning.allow_downloading_unscanned_files
  block_all_except_clean = var.file_malwarescanning.enabled && !var.file_malwarescanning.allow_downloading_unscanned_files
}

# --- Writers policy statements ---
data "aws_iam_policy_document" "bucket_policy" {
  count = local.has_bucket_policy ? 1 : 0

  # Writers: Allow ELB service account to put objects
  dynamic "statement" {
    for_each = var.writers
    content {
      effect  = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        "${aws_s3_bucket.main.arn}/${statement.value.prefix}/*",
      ]
      principals {
        type        = "AWS"
        identifiers = [data.aws_elb_service_account.main.arn]
      }
    }
  }

  # Writers: Allow delivery.logs.amazonaws.com to put objects
  dynamic "statement" {
    for_each = var.writers
    content {
      effect  = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        "${aws_s3_bucket.main.arn}/${statement.value.prefix}/*",
      ]
      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
    }
  }

  # Writers: Allow delivery.logs.amazonaws.com to get bucket ACL
  dynamic "statement" {
    for_each = local.has_writers ? [1] : []
    content {
      effect  = "Allow"
      actions = ["s3:GetBucketAcl"]
      resources = [
        aws_s3_bucket.main.arn,
      ]
      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
    }
  }

  # --- Malware scanning: Permissive mode ---
  # Block downloads of objects explicitly tagged as THREATS_FOUND
  dynamic "statement" {
    for_each = local.block_infected_only ? [1] : []
    content {
      sid    = "DenyInfectedDownloads"
      effect = "Deny"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
      ]
      resources = [
        "${aws_s3_bucket.main.arn}/*",
      ]
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:ExistingObjectTag/GuardDutyMalwareScanStatus"
        values   = ["THREATS_FOUND"]
      }
    }
  }

  # --- Malware scanning: Strict mode ---
  # Block downloads of objects NOT tagged as NO_THREATS_FOUND
  dynamic "statement" {
    for_each = local.block_all_except_clean ? [1] : []
    content {
      sid    = "DenyUnscannedDownloads"
      effect = "Deny"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
      ]
      resources = [
        "${aws_s3_bucket.main.arn}/*",
      ]
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      condition {
        test     = "StringNotEquals"
        variable = "s3:ExistingObjectTag/GuardDutyMalwareScanStatus"
        values   = ["NO_THREATS_FOUND"]
      }
      condition {
        test     = "StringNotLike"
        variable = "aws:PrincipalArn"
        values   = [aws_iam_role.guardduty_malware_protection[0].arn]
      }
    }
  }

  # Block downloads of objects missing the scan tag entirely
  dynamic "statement" {
    for_each = local.block_all_except_clean ? [1] : []
    content {
      sid    = "DenyMissingScanTagDownloads"
      effect = "Deny"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
      ]
      resources = [
        "${aws_s3_bucket.main.arn}/*",
      ]
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      condition {
        test     = "Null"
        variable = "s3:ExistingObjectTag/GuardDutyMalwareScanStatus"
        values   = ["true"]
      }
      condition {
        test     = "StringNotLike"
        variable = "aws:PrincipalArn"
        values = [
          aws_iam_role.guardduty_malware_protection[0].arn,
          "arn:aws:iam::*:role/gd-backfill-lambda-*",
          "arn:aws:sts::*:assumed-role/gd-backfill-lambda-*/*"
        ]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  count = local.has_bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}

