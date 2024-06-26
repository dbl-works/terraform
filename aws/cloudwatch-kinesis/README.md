Stream logs from AWS Cloudwatch to Kinesis Firehose.

From Firehose, we can access and process the logs e.g using vector.

Vector will then transform the logs and forward them to e.g. Snowflake, Logtail, and S3.

High level overview:

Kinesis --> send logs via http to ECS cluster that runs vector --> vector transforms logs --> vector sends logs to Snowflake, Logtail, and S3

```terraform
data "aws_secretsmanager_secret_version" "app" {
  name = "${local.project}/app/${local.environment}"
}

locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.app.secret_string
  )
}

module "cloudwatch-kinesis" {
  source = "github.com/dbl-works/terraform//cloudwatch-kinesis?ref=v2023.03.30"

  project = local.project
  environment = local.environment

  # Optional
  kinesis_stream_name = "kinesis-aws"
  region = "us-east-1"
  subscription_log_group_names = ["/ecs/facebook-staging"]
  s3_output_prefix = "raw/"
  s3_error_output_prefix = "errors/"
  enable_dynamic_partitioning = true
  cloudwatch_logs_retention_in_days = 7
  kinesis_destination = "s3"

  http_endpoint_configuration = {
    url                = "https://logtail.com"
    access_key         = local.credentials["ACCESS_KEY"]
    buffering_size     = 1 # MB
    buffering_interval = 60 # s
    s3_backup_mode     = 'AllData'
    enable_cloudwatch  = true
    content_encoding   = "NONE"
  }

  s3_configuration = {
    s3_bucket_arn      = "arn:aws:s3:::cloudwatch-logs"
    buffering_interval = 60
    buffering_size     = 64 # Must be at least 64 when dynamic partitioning
    enable_cloudwatch  = true
    kms_arn            = "arn:aws:kms:xxxxxx"
    compression_format = "UNCOMPRESSED"
    processors = {
      Lambda = [
        {
          parameter_name = "LambdaArn"
          parameter_value = "arn:aws:lambda:xxxxxx"
        }
      ]
      MetadataExtraction = [
        {
          parameter_name = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        },
        {
          parameter_name = "MetadataExtractionQuery"
          parameter_value = "{customer_name:.customer_name}"
        }
      ]
    }
  }
}
```
