# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#FirehoseExample
resource "aws_iam_role" "main" {
  name = "subscription-filter-to-firehose"

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

resource "aws_iam_policy" "main" {
  name = "subscription-filter-to-firehose-policy"

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
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_cloudwatch_log_subscription_filter" "main" {
  name            = local.ecs_cluster_name
  role_arn        = aws_iam_role.main.arn
  filter_pattern  = ""
  log_group_name  = "/ecs/${local.ecs_cluster_name}"
  destination_arn = aws_kinesis_firehose_delivery_stream.main.arn
  distribution    = "ByLogStream"
}
