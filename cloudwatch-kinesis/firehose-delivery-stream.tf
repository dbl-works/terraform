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

locals {
  s3_policy = var.s3_configuration == null ? [] : [
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
        var.s3_configuration.s3_bucket_arn,
        "${var.s3_configuration.s3_bucket_arn}/*"
      ]
    }
  ]
  s3_encryption_policy = try(var.s3_configuration.kms_arn, null) != null ? [
    {
      "Effect" : "Allow",
      "Action" : [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource" : [
        var.s3_configuration.kms_arn
      ]
    }
  ] : []
  lambda_policy = try(var.s3_configuration.aws_lambda_arn, null) != null ? [
    {
      "Action" : [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Effect" : "Allow",
      "Resource" : [
        "${var.s3_configuration.aws_lambda_arn}:*"
      ]
    }
  ] : []
}

resource "aws_iam_policy" "kinesis" {
  name = "kinesis-policy-${local.name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : concat([
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
    ], local.s3_policy, local.s3_encryption_policy, local.lambda_policy)
  })
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  role       = aws_iam_role.kinesis.name
  policy_arn = aws_iam_policy.kinesis.arn
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = var.kinesis_stream_name == null ? local.name : var.kinesis_stream_name
  destination = var.http_endpoint_configuration == null ? var.kinesis_destination : "http_endpoint"

  # Use this when the destination is not s3 but we want to backup using s3
  dynamic "s3_configuration" {
    for_each = var.s3_configuration != null && !contains(["s3", "extended_s3"], var.kinesis_destination) ? [var.s3_configuration] : []

    content {
      role_arn           = aws_iam_role.kinesis.arn
      bucket_arn         = s3_configuration.value.s3_bucket_arn
      buffer_size        = s3_configuration.value.buffering_size     # in MB
      buffer_interval    = s3_configuration.value.buffering_interval # in seconds
      compression_format = s3_configuration.value.compression_format

      # https://docs.aws.amazon.com/firehose/latest/dev/s3-prefixes.html
      # Sample: myPrefix/result=!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd} => myPrefix/result=processing-failed/2018/08/03
      prefix              = "logs/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}"
      error_output_prefix = "errors/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}-!{firehose:error-output-type}"

      cloudwatch_logging_options {
        enabled         = s3_configuration.value.enable_cloudwatch
        log_group_name  = local.log_group_name
        log_stream_name = "s3"
      }
    }
  }

  # Use this when the destination is s3
  dynamic "extended_s3_configuration" {
    for_each = var.s3_configuration != null && contains(["s3", "extended_s3"], var.kinesis_destination) ? [var.s3_configuration] : []

    content {
      role_arn           = aws_iam_role.kinesis.arn
      bucket_arn         = extended_s3_configuration.value.s3_bucket_arn
      buffer_size        = extended_s3_configuration.value.buffering_size     # in MB
      buffer_interval    = extended_s3_configuration.value.buffering_interval # in seconds
      compression_format = extended_s3_configuration.value.compression_format

      # https://docs.aws.amazon.com/firehose/latest/dev/s3-prefixes.html
      # Sample: myPrefix/result=!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd} => myPrefix/result=processing-failed/2018/08/03
      prefix              = "logs/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}"
      error_output_prefix = "errors/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}-!{firehose:error-output-type}"

      cloudwatch_logging_options {
        enabled         = extended_s3_configuration.value.enable_cloudwatch
        log_group_name  = local.log_group_name
        log_stream_name = "s3"
      }

      processing_configuration {
        enabled = extended_s3_configuration.value.aws_lambda_arn != null

        dynamic "processors" {
          for_each = extended_s3_configuration.value.aws_lambda_arn == null ? [] : [extended_s3_configuration.value.aws_lambda_arn]

          content {
            type = "Lambda"

            parameters {
              parameter_name  = "LambdaArn"
              parameter_value = "${processors.value}:$LATEST"
            }
          }
        }
      }
    }
  }

  dynamic "http_endpoint_configuration" {
    for_each = var.http_endpoint_configuration == null ? [] : [var.http_endpoint_configuration]

    content {
      url                = http_endpoint_configuration.value.url
      name               = "${local.name}-http-endpoint"
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
        # the key names follow Open Telemetry Semantic Conventions, see: https://opentelemetry.io/docs/concepts/semantic-conventions/
        common_attributes {
          name  = "deployment.environment"
          value = var.environment
        }

        common_attributes {
          name  = "service.name"
          value = var.project
        }

        common_attributes {
          name  = "cloud.region"
          value = var.region
        }
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
  count = try(var.http_endpoint_configuration.enable_cloudwatch, false) ? 1 : 0

  name           = "http"
  log_group_name = local.log_group_name

  depends_on = [aws_cloudwatch_log_group.main]
}

resource "aws_cloudwatch_log_stream" "s3" {
  count = try(var.s3_configuration.enable_cloudwatch, false) ? 1 : 0

  name           = "s3"
  log_group_name = local.log_group_name
  depends_on     = [aws_cloudwatch_log_group.main]
}
