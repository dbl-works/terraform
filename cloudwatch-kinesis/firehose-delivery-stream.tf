data "aws_lb" "main" {
  name = local.ecs_cluster_name
}

data "aws_iam_role" "ecs-task-execution" {
  name = "ecs-task-execution-${local.ecs_cluster_name}"
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "${var.project}-${var.environment}-main"
  destination = "http_endpoint"

  s3_configuration {
    role_arn           = data.aws_iam_role.ecs-task-execution.arn
    bucket_arn         = var.log_bucket_arn
    buffer_size        = var.buffer_size_for_s3     # in MB
    buffer_interval    = var.buffer_interval_for_s3 # in seconds
    compression_format = "GZIP"
  }

  http_endpoint_configuration {
    url                = "${data.aws_lb.main.dns_name}:${var.ecs_http_port}"
    name               = local.ecs_cluster_name
    buffering_size     = var.buffer_size_for_http_endpoint
    buffering_interval = var.buffer_interval_for_http_endpoint
    role_arn           = data.aws_iam_role.ecs-task-execution.arn
    s3_backup_mode     = "FailedDataOnly"

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
}
