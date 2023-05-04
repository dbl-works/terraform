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
  region = "us-east-1"
  ecs_cluster_name = "facebook-staging"
  ecs_http_port = 5073
  log_bucket_arn = "arn:aws:s3:::cloudwatch-logs"
  s3_kms_arn = "arn:aws:kms:eu-central-1:xxxxxxx:key:can-t-be-blank"
  buffer_size_for_s3 = 10
  buffer_interval_for_s3 = 400
  enable_cloudwatch = true

  http_endpoint_configuration = {
    url                = "https://logtail.com"
    access_key         = local.credentials["ACCESS_KEY"]
    buffering_size     = 1 # MB
    buffering_interval = 60 # s
    s3_backup_mode     = 'AllData'
    enable_cloudwatch  = true
    content_encoding   = "NONE"
  }
}
```
