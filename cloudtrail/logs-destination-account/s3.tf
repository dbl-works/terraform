locals {
  cloudtrail_s3_bucket_name = "${var.organization_name}-cloudtrail"
}

module "s3-cloudtrail" {
  source = "../../s3-private"

  # Required
  environment = var.environment
  project     = var.organization_name
  bucket_name = local.cloudtrail_s3_bucket_name
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudtrail_only" {
  bucket = module.s3-cloudtrail.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudtrail_only.json
}

# https://stackoverflow.com/questions/73159162/cloudtrail-insufficient-permissions-to-access-s3-bucket
data "aws_iam_policy_document" "allow_access_from_cloudtrail_only" {
  statement {
    sid     = "AllowCloudtrailWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = flatten([
      for account_id in var.logging_account_ids : [
        "${module.s3-cloudtrail.arn}/prefix/AWSLogs/${account_id}/*"
      ]
    ])

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
      values = flatten([
        for account_id in var.logging_account_ids : [
          "arn:*:cloudtrail:*:${account_id}:trail/*"
        ]
      ])
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
      module.s3-cloudtrail.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      # AWS has different partitions for public cloud, China regions, and the AWS GovCloud (US) regions.
      values = flatten([
        for account_id in var.logging_account_ids : [
          "arn:*:cloudtrail:*:${account_id}:trail/*"
        ]
      ])
    }
  }
}
