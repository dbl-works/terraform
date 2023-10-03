locals {
  management_cloudtrail_name = "${var.organization_name}-management-logs"
  data_cloudtrail_name       = "${var.organization_name}-data-logs"
}

# Although CloudTrail provides 90 days of event history information for management events in the CloudTrail console without creating a trail,
# it is not a permanent record, and it does not provide information about all possible types of events.
resource "aws_cloudtrail" "management" {
  count = var.enable_management_cloudtrail ? 1 : 0

  name                          = local.management_cloudtrail_name
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.main.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = module.cloudtrail-kms.id
  s3_bucket_name                = module.cloudtrail-s3.id
  s3_key_prefix                 = "management"

  advanced_event_selector {
    name = "Log readOnly and writeOnly management events"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  tags = {
    Name        = local.management_cloudtrail_name
    Project     = var.organization_name
    Environment = var.environment
  }
}

resource "aws_cloudtrail" "data" {
  count = var.enable_data_cloudtrail ? 1 : 0

  name                          = local.data_cloudtrail_name
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.main.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = module.cloudtrail-kms.id
  s3_bucket_name                = module.cloudtrail-s3.id
  s3_key_prefix                 = "data"

  event_selector {

  }

  advanced_event_selector {
    name = "Log all data events"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
  }

  tags = {
    Name        = local.data_cloudtrail_name
    Project     = var.organization_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = local.cloudtrail_name
}

# This CloudWatch Group is used for storing CloudTrail logs.
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = module.cloudtrail-kms.id
  tags              = var.tags
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.logging_account_id}:root",
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
      }
    ]
  })
}

// NOTE:
resource "aws_iam_role_policy_attachment" "cloudtrail_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.cloudtrail_role.name
}


data "aws_iam_policy_document" "example" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.example.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/example"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    # TODO
    resources = ["${aws_s3_bucket.example.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

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
}

data "aws_region" "current" {}
