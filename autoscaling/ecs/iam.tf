resource "aws_iam_role" "ecs-autoscale-role" {
  count = var.ecs_autoscale_role_arn == null ? 1 : 0
  name  = "ecs-scale-application"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-autoscale" {
  count      = var.ecs_autoscale_role_arn == null ? 1 : 0
  role       = aws_iam_role.ecs-autoscale-role[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch" {
  count      = var.ecs_autoscale_role_arn == null ? 1 : 0
  role       = aws_iam_role.ecs-autoscale-role[0].id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
