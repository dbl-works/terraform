locals {
  management_cloudtrail_name = "${var.organization_name}-management-cloudtrail-logs"
  data_cloudtrail_name       = "${var.organization_name}-data-cloudtrail-logs"
  cloudtrail_name            = "${var.organization_name}-cloudtrail-logs"
}

data "aws_caller_identity" "current" {}

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
  kms_key_id                    = var.cloudtrail_s3_kms_arn
  s3_bucket_name                = var.cloudtrail_s3_bucket_name

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    exclude_management_event_sources = [
      # AWS KMS actions such as Encrypt, Decrypt, and GenerateDataKey typically generate a large volume (more than 99%) of events.
      "kms.amazonaws.com",
      # CloudTrail captures all API calls for Data API as events, including calls from the Amazon RDS console and from code calls to the Data API operations
      # However, the Data API can generate a large number of events,
      "rdsdata.amazonaws.com"
    ]
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
  kms_key_id                    = var.cloudtrail_s3_kms_arn
  s3_bucket_name                = var.cloudtrail_s3_bucket_name

  advanced_event_selector {
    name = "Log Delete* events for one S3 bucket"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field       = "eventName"
      starts_with = ["Delete"]
    }

    field_selector {
      field  = "resources.ARN"
      equals = var.s3_bucket_arn_for_data_cloudtrail
    }

    field_selector {
      field  = "readOnly"
      equals = ["false"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
  }

  tags = {
    Name        = local.data_cloudtrail_name
    Project     = var.organization_name
    Environment = var.environment
  }
}

# This CloudWatch Group is used for storing CloudTrail logs.
resource "aws_cloudwatch_log_group" "main" {
  name = local.cloudtrail_name

  retention_in_days = var.log_retention_days
  tags = {
    Name        = local.cloudtrail_name
    Project     = var.organization_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "${var.organization_name}-cloudtrail-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
      }
    ]
  })

  tags = {
    Name        = "${var.organization_name}-cloudtrail-role"
    Project     = var.organization_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "cloudtrail_role_policy" {
  policy_arn = aws_iam_policy.cloudtrail_role_policy.arn
  role       = aws_iam_role.cloudtrail_role.name
}


resource "aws_iam_policy" "cloudtrail_role_policy" {
  name   = "${var.organization_name}-cloudtrail-role-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cloudtrail_role_policy.json
}

data "aws_iam_policy_document" "cloudtrail_role_policy" {
  statement {
    sid = "AllowCloudtrailAccess"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowS3KMSKeyAccess"
    actions = [
      "kms:GenerateDataKey*",
    ]
    resources = [
      var.cloudtrail_s3_kms_arn,
    ]
  }
}
