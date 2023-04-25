data "aws_ecs_cluster" "main" {
  cluster_name = local.ecs_cluster_name
}

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
    role_arn           = aws_iam_role.ecs-task-execution.arn
    bucket_arn         = variable.log_bucket_arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }

  http_endpoint_configuration {
    url                = "${data.aws_lb.main.dns_name}:${var.ecs_http_port}"
    name               = local.ecs_cluster_name
    buffering_size     = 1   # MB
    buffering_interval = 600 # 1 minute
    role_arn           = aws_iam_role.ecs-task-execution.arn
    s3_backup_mode     = "FailedDataOnly"

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "envionment"
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
