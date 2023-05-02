data "aws_lb" "main" {
  name = local.ecs_cluster_name
}

resource "aws_iam_role" "kinesis" {
  name = "firehose-task-execution-${local.name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
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
  name = "firehose-task-execution-${local.name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "kinesis:DescribeStream",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
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
  destination = "http_endpoint"

  # Required for non-S3 destinations
  s3_configuration {
    role_arn           = data.aws_iam_role.ecs-task-execution.arn
    bucket_arn         = var.log_bucket_arn
    buffer_size        = var.buffer_size_for_s3     # in MB
    buffer_interval    = var.buffer_interval_for_s3 # in seconds
    compression_format = "GZIP"
    cloudwatch_logging_options {
      enabled         = var.enable_cloudwatch
      log_group_name  = "kinesis/${local.ecs_cluster_name}"
      log_stream_name = "s3"
    }
  }

  http_endpoint_configuration {
    url                = var.http_endpoint_url == null ? "${data.aws_lb.main.dns_name}:${var.ecs_http_port}" : var.http_endpoint_url
    name               = local.ecs_cluster_name
    buffering_size     = var.buffer_size_for_http_endpoint
    buffering_interval = var.buffer_interval_for_http_endpoint
    role_arn           = data.aws_iam_role.ecs-task-execution.arn
    s3_backup_mode     = "FailedDataOnly"
    cloudwatch_logging_options {
      enabled         = var.enable_cloudwatch
      log_group_name  = "kinesis/${local.ecs_cluster_name}"
      log_stream_name = "http"
    }

    request_configuration {
      content_encoding = "GZIP"

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
