# Not sure whether user can manage Tag and iam role
data "aws_iam_policy_document" "admin" {
  statement {
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values = [var.environment]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values = [var.environment]
    }
  }
}

resource "aws_iam_policy" "admin-usage-for-taggable-resources" {
  name        = "TaggableResourcesAdminUsage"
  path        = "/"
  description = "Allow admins to access all taggable resources in the project"

  policy = data.aws_iam_policy_document.admin.json
}
