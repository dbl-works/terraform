data "aws_iam_policy_document" "ecs_ssm" {
  statement {
    sid = "AllowSsmTerminateSession"
    actions = [
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:DescribeInstanceProperties",
      "ec2:DescribeInstances"
    ]
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*"
    ]
  }
}
