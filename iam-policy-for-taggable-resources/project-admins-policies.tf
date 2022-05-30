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
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/${var.environment}-admin-access-projects}"]
    }
  }
}
