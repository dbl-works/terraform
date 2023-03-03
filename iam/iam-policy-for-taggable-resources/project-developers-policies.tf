data "aws_iam_policy_document" "developer" {
  statement {
    sid = "AllowDeveloperAccessBasedOnTags"
    actions = flatten([for resource in local.resources : [
      "${resource}:Get*",
      # The batch commands are to include some of the ecr permissions, e.g. ecr:BatchCheckLayerAvailability, ecr:BatchGetImage
      "${resource}:BatchGet*",
      "${resource}:BatchCheck*"
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
}

# "List" and "Describe" cannot be matched using tags
data "aws_iam_policy_document" "read_access" {
  statement {
    sid = "AllowReadAccess"
    actions = flatten([for resource in concat(local.resources, local.admin_resources) : [
      "${resource}:Describe*",
      "${resource}:List*"
    ]])

    resources = ["*"]
  }
}
