data "aws_iam_policy_document" "admin" {
  statement {
    sid       = "AllowAdminAccessBasedOnTags"
    actions   = ["*"]
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
      values   = ["&{aws:PrincipalTag/${var.environment}-admin-access-projects}"]
    }
  }
}

data "aws_iam_policy_document" "secret_manager" {
  statement {
    sid = "AllowSecretAccessBasedOnTags"
    actions = flatten([for resource in local.admin_resources : [
      "${resource}:*",
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
      values   = ["&{aws:PrincipalTag/${var.environment}-admin-access-projects}"]
    }
  }
}
