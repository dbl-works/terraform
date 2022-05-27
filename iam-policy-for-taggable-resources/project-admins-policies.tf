# TODO: Not sure whether user can manage Tag and iam role
data "aws_iam_policy_document" "admin" {
  statement {
    sid = "AllowAdminAccessBasedOnTags"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values = [var.environment]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values = ["&{aws:PrincipalTag/${var.environment}-admin-access-projects}"]
    }
  }
}

data "aws_iam_policy_document" "developer" {
  statement {
    sid = "AllowDeveloperAccessBasedOnTags"
    actions = [
        "aws:Describe*",
        "aws:Get*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values = [var.environment]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values = ["&{aws:PrincipalTag/${var.environment}-developer-access-projects}"]
    }
  }
}

# TODO: Would this be too generous to allow the user to see the following list?
# TODO: Move this to non-taggable resources
# List action generally does not support resource-level permissions
# https://stackoverflow.com/questions/58993574/iam-policy-with-awsresourcetag-not-supported
data "aws_iam_policy_document" "list" {
  statement {
    sid = "AllowListAccessToAllResources"
    actions = [
        "secretsmanager:List*",
        "kms:List*",
        "s3:List*",
        "ecr:List*",
        "ecs:List*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "taggable-resources" {
  source_policy_documents = [
    data.aws_iam_policy_document.admin.json,
    data.aws_iam_policy_document.developer.json,
    data.aws_iam_policy_document.list.json
  ]
}

resource "aws_iam_policy" "taggable-resources" {
  name        = "TaggableResourcesAccessOn${title(var.environment)}"
  path        = "/"
  description = "Allow access to taggable resources based on project on ${var.environment}"

  policy = data.aws_iam_policy_document.taggable-resources.json
}
