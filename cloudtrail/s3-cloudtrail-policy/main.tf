resource "aws_s3_bucket_policy" "allow_access_from_cloudtrail_only" {
  bucket = var.cloudtrail_s3_bucket_name
  policy = data.aws_iam_policy_document.allow_access_from_cloudtrail_only.json
}

# https://stackoverflow.com/questions/73159162/cloudtrail-insufficient-permissions-to-access-s3-bucket
data "aws_iam_policy_document" "allow_access_from_cloudtrail_only" {
  statement {
    sid     = "AllowCloudtrailWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.cloudtrail_s3_bucket_name}/AWSLogs/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = var.cloudtrail_arns
    }
  }

  statement {
    sid    = "AllowCloudtrailACLCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${var.cloudtrail_s3_bucket_name}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = var.cloudtrail_arns
    }
  }
}
