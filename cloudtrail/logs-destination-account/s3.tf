locals {
  cloudtrail_s3_bucket_name = "${var.organization_name}-cloudtrail"
}

module "s3-cloudtrail" {
  source = "../s3-private"

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
    actions = ["s3:PutObject"]
    resources = [
      "${module.s3-cloudtrail.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = var.cloudtrail_roles
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/example"]
    }
  }

  statement {
    sid = "AllowCloudtrailACLCheck"
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
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/example"]
    }
  }
}

data "aws_partition" "current" {}
