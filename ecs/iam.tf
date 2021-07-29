# Grant access to list and describe clusters
resource "aws_iam_group" "ecs-view" {
  name = "${var.project}-${var.environment}-ecs-view"
}
resource "aws_iam_policy" "ecs-view" {
  name        = "${var.project}-${var.environment}-ecs-view"
  path        = "/"
  description = "Allow viewing ECS clusters for ${var.project} ${var.environment}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:Get*",
        "ecs:List*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "${var.project}",
          "aws:ResourceTag/Environment": "${var.environment}"
        }
      },
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "ecs-view" {
  group      = aws_iam_group.ecs-view.name
  policy_arn = aws_iam_policy.ecs-view.arn
}



# Grant access to console
resource "aws_iam_group" "ecs-console" {
  name = "${var.project}-${var.environment}-ecs-console"
}
resource "aws_iam_policy" "ecs-console" {
  name        = "${var.project}-${var.environment}-ecs-console"
  path        = "/"
  description = "Allow console into ECS clusters for ${var.project} ${var.environment}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:StartSession"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "${var.project}",
          "aws:ResourceTag/Environment": "${var.environment}"
        }
      },
      "Resource": [
        "*",
        "arn:aws:ssm:${var.region}:*:document/AmazonECS-ExecuteInteractiveCommand"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ssm:DescribeInstanceProperties",
        "ec2:DescribeInstances"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "${var.project}",
          "aws:ResourceTag/Environment": "${var.environment}"
        }
      },
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "${var.project}",
          "aws:ResourceTag/Environment": "${var.environment}"
        }
      },
      "Resource": [
        "arn:aws:ssm:*:*:session/$${aws:username}-*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "ecs-console" {
  group      = aws_iam_group.ecs-console.name
  policy_arn = aws_iam_policy.ecs-console.arn
}

