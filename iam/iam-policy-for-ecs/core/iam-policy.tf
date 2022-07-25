data "aws_iam_policy_document" "ecs_iam" {
  statement {
    sid = "AllowIamPassRole"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    sid = "AllowIamListRole"
    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfiles",
      "iam:ListRoles"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowEcsInstanceRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ecsInstanceRole*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com",
        "ec2.amazonaws.com.cn"
      ]
    }
  }

  statement {
    sid = "AllowEcsAutoscaleRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ecsAutoscaleRole*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "application-autoscaling.amazonaws.com",
        "application-autoscaling.amazonaws.com.cn"
      ]
    }
  }

  statement {
    sid = "AllowCreateServiceLinkedRole"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values = [
        "autoscaling.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs.application-autoscaling.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com"
      ]
    }
  }
}
