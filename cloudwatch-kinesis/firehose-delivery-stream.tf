# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#FirehoseExample
resource "aws_iam_role" "kinesis" {
  name = "kinesis-${local.name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "kinesis" {
  name = "kinesis-policy-${local.name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          var.log_bucket_arn,
          "${var.log_bucket_arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        "Resource" : [
          var.s3_kms_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  role       = aws_iam_role.kinesis.name
  policy_arn = aws_iam_policy.kinesis.arn
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = local.name
  destination = var.http_endpoint_url == null ? var.kinesis_destination : "http_endpoint"

  # Required for non-S3 destinations
  s3_configuration {
    role_arn           = aws_iam_role.kinesis.arn
    bucket_arn         = var.log_bucket_arn
    buffer_size        = var.buffer_size_for_s3     # in MB
    buffer_interval    = var.buffer_interval_for_s3 # in seconds
    compression_format = "GZIP"

    # https://docs.aws.amazon.com/firehose/latest/dev/s3-prefixes.html
    # Sample: myPrefix/result=!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd} => myPrefix/result=processing-failed/2018/08/03
    prefix              = "logs/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}"
    error_output_prefix = "errors/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}-!{firehose:error-output-type}"

    cloudwatch_logging_options {
      enabled         = var.enable_cloudwatch
      log_group_name  = local.log_group_name
      log_stream_name = "s3"
    }
  }

  dynamic "http_endpoint_configuration" {
    for_each = [var.http_endpoint_configuration]

    url                = http_endpoint_configuration.value.url
    name               = local.ecs_cluster_name
    access_key         = http_endpoint_configuration.value.access_key
    buffering_size     = http_endpoint_configuration.value.buffering_size
    buffering_interval = http_endpoint_configuration.value.buffering_interval
    role_arn           = aws_iam_role.kinesis.arn
    s3_backup_mode     = http_endpoint_configuration.value.s3_backup_mode

    cloudwatch_logging_options {
      enabled         = http_endpoint_configuration.value.enable_cloudwatch
      log_group_name  = local.log_group_name
      log_stream_name = "http"
    }

    request_configuration {
      content_encoding = http_endpoint_configuration.value.content_encoding

      # Describes the metadata sent to the HTTP endpoint destination
      common_attributes {
        name  = "environment"
        value = var.environment
      }

      common_attributes {
        name  = "project"
        value = var.project
      }

      common_attributes {
        name  = "region"
        value = var.region
      }
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name              = local.log_group_name
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_stream" "http_endpoint" {
  name           = "http"
  log_group_name = local.log_group_name

  depends_on = [aws_cloudwatch_log_group.main]
}

resource "aws_cloudwatch_log_stream" "s3" {
  name           = "s3"
  log_group_name = local.log_group_name
  depends_on     = [aws_cloudwatch_log_group.main]
}
