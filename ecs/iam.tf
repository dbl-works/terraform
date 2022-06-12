# https://docs.aws.amazon.com/AmazonECS/latest/userguide/security_iam_service-with-iam.html

# Grant access to list and describe clusters
resource "aws_iam_group" "ecs-view" {
  name = "${local.name}-ecs-view"
}
resource "aws_iam_policy" "ecs-view" {
  name        = "${local.name}-ecs-view"
  path        = "/"
  description = "Allow viewing ECS clusters for ${local.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeClusters",
        "ecs:ListClusters"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:Get*",
        "ecs:List*"
      ],
      "Resource": [
        "arn:aws:ecs:*:*:task-definition/*",
        "arn:aws:ecs:*:*:cluster/${local.name}",
        "arn:aws:ecs:*:*:container/${local.name}/*",
        "arn:aws:ecs:*:*:container-instance/${local.name}/*",
        "arn:aws:ecs:*:*:service/${local.name}/*",
        "arn:aws:ecs:*:*:task/${local.name}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*",
        "logs:Describe*",
        "logs:Get*",
        "logs:FilterLogEvents"
      ],
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
  name = "${local.name}-ecs-console"
}
resource "aws_iam_policy" "ecs-console" {
  name        = "${local.name}-ecs-console"
  path        = "/"
  description = "Allow console into ECS clusters for ${local.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": [
        "arn:aws:ecs:*:*:task-definition/*",
        "arn:aws:ecs:*:*:cluster/${local.name}",
        "arn:aws:ecs:*:*:container/${local.name}/*",
        "arn:aws:ecs:*:*:container-instance/${local.name}/*",
        "arn:aws:ecs:*:*:service/${local.name}/*",
        "arn:aws:ecs:*:*:task/${local.name}/*"
      ]
    },
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
        "arn:aws:ssm:*:*:session/$${aws:username}-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:session/$${aws:username}-*"
      ]
    },
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringLike": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    },
    {
      "Action": [
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfiles",
        "iam:ListRoles"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:iam::*:role/ecsInstanceRole*"
      ],
      "Condition": {
        "StringLike": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "ec2.amazonaws.com.cn"
          ]
        }
      }
    },
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:iam::*:role/ecsAutoscaleRole*"
      ],
      "Condition": {
        "StringLike": {
          "iam:PassedToService": [
            "application-autoscaling.amazonaws.com",
            "application-autoscaling.amazonaws.com.cn"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": [
            "autoscaling.amazonaws.com",
            "ecs.amazonaws.com",
            "ecs.application-autoscaling.amazonaws.com",
            "spot.amazonaws.com",
            "spotfleet.amazonaws.com"
          ]
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "ecs-console" {
  group      = aws_iam_group.ecs-console.name
  policy_arn = aws_iam_policy.ecs-console.arn
}

