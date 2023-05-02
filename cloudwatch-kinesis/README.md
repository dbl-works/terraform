Stream logs from AWS Cloudwatch to Kinesis Firehose.

From Firehose, we can access and process the logs e.g using vector.

Vector will then transform the logs and forward them to e.g. Snowflake, Logtail, and S3.

High level overview:

Kinesis --> send logs via http to ECS cluster that runs vector --> vector transforms logs --> vector sends logs to Snowflake, Logtail, and S3

```terraform
module "cloudwatch-kinesis" {
  source = "github.com/dbl-works/terraform//cloudwatch-kinesis?ref=v2023.03.30"

  project = local.project
  environment = local.environment

  # Optional
  region = "us-east-1"
  ecs_cluster_name = "facebook-staging"
  ecs_http_port = 5073
  log_bucket_arn = "arn:aws:s3:::cloudwatch-logs"
  buffer_size_for_s3 = 10
  buffer_interval_for_s3 = 400
  buffer_size_for_http_endpoint = 1
  buffer_interval_for_http_endpoint = 60
  enable_cloudwatch = true
}
```
