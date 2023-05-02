resource "aws_iam_role" "subscription_filter" {
  name = "subscription-filter-to-firehose-${local.name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "subscription_filter" {
  name = "subscription-filter-to-firehose-${local.name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "firehose:PutRecord",
        ],
        "Effect" : "Allow",
        "Resource" : [
          aws_kinesis_firehose_delivery_stream.main.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "subscription_filter" {
  role       = aws_iam_role.subscription_filter.name
  policy_arn = aws_iam_policy.subscription_filter.arn
}

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  name            = local.ecs_cluster_name
  role_arn        = aws_iam_role.subscription_filter.arn
  filter_pattern  = ""
  log_group_name  = "/ecs/${local.ecs_cluster_name}"
  destination_arn = aws_kinesis_firehose_delivery_stream.main.arn
  distribution    = "ByLogStream"
}
