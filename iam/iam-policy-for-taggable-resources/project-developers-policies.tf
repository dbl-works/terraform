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
    sid = "AllowDeveloperAccessBasedOnTags"
    actions = flatten([for resource in local.resources : [
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
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/${var.environment}-developer-access-projects}"]
    }
  }

  # "List" cannot be matched using tags
  statement {
    sid = "AllowDeveloperListAccess"
    actions = flatten([for resource in local.resources : [
      "${resource}:List*"
    ]])

    resources = ["*"]
  }
}
