locals {
  sid_name = var.project_name != null ? "${title(var.environment)}-${title(var.project_name)}" : title(var.environment)
}

data "aws_iam_policy_document" "ssm_policy" {
  statement {
    sid = "AllowSsmStartSession${local.sid_name}"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "*",
      "arn:aws:ssm:${var.region}:*:document/AmazonECS-ExecuteInteractiveCommand"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }

    condition {
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = var.project_name != null ? "StringEquals" : "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = var.project_name != null ? [var.project_name] : ["&{aws:PrincipalTag/${var.project_tag}}"]
    }
  }

  statement {
    sid = "AllowSsmControlSession${local.sid_name}"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }

    condition {
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = var.project_name != null ? "StringEquals" : "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = var.project_name != null ? [var.project_name] : ["&{aws:PrincipalTag/${var.project_tag}}"]
    }
  }
}
