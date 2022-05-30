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

data "aws_iam_policy_document" "deny_invalid_env_developer_access" {
  statement {
    sid    = "DenyDeveloperAccessForInvalidEnvironment"
    effect = "Deny"
    actions = flatten([for resource in local.resources : [
      "${resource}:Describe*",
      "${resource}:Get*"
    ]])

    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }

  }
}

data "aws_iam_policy_document" "deny_invalid_project_developer_access" {
  statement {
    sid    = "DenyDeveloperAccessForInvalidProject"
    effect = "Deny"
    actions = flatten([for resource in local.resources : [
      "${resource}:Describe*",
      "${resource}:Get*"
    ]])

    resources = ["*"]

    condition {
      test     = "StringNotLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/${var.environment}-developer-access-projects}"]
    }
  }
}

data "aws_iam_policy_document" "developer" {
  statement {
    sid = "AllowListAccessToAllResources"
    actions = flatten([for resource in local.resources : [
      "${resource}:List*",
      "${resource}:Describe*",
      "${resource}:Get*"
    ]])

    resources = ["*"]
  }
}
