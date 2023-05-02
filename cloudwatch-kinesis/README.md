Stream logs from AWS Cloudwatch to Kinesis Firehose.

From Firehose, we can access and process the logs e.g using vector.

Vector will then transform the logs and forward them to e.g. Snowflake, Logtail, and S3.


High level overview:

Kinesis --> send logs via http to ECS cluster that runs vector --> vector transforms logs --> vector sends logs to Snowflake, Logtail, and S3
