locals {
  resources = [
    "acm",
    "cloudwatch",
    "cognito-identity",
    "cognito-idp",
    "ecr",
    "ecs",
    "ec2",
    "elasticloadbalancing",
    "elasticache",
    "kms",
    "s3",
    "secretsmanager",
    "rds",
  ]
}

data "aws_iam_policy_document" "developer" {
  statement {
    sid = "AllowDeveloperAccessToAllResources"
    actions = flatten([for resource in local.resources : [
      "${resource}:List*",
      "${resource}:Describe*",
      "${resource}:Get*"
    ]])

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/${var.environment}-developer-access-projects}"]
    }
  }
}
