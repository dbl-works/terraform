locals {
  # must be alpha-numeric
  sid_name = replace(
    title(var.project_name != null ? "${title(var.environment)}-${title(var.project_name)}" : title(var.environment)),
    "/[^0-9A-Za-z]/",
    ""
  )
}

data "aws_iam_policy_document" "redshift_serverless_policy" {
  statement {
    sid = "AllowRedshiftServerlessGetCredentials${local.sid_name}"
    actions = [
      "redshift-serverless:GetCredentials"
    ]
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
      test     = var.project_name != null ? "StringEquals" : "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = var.project_name != null ? [var.project_name] : ["&{aws:PrincipalTag/${var.project_tag}}"]
    }
  }

  statement {
    sid = "AllowRedshiftServerlessListDescribe${local.sid_name}"
    actions = [
      "redshift-serverless:GetWorkgroup",
      "redshift-serverless:ListWorkgroups",
      "redshift-serverless:GetNamespace",
      "redshift-serverless:ListNamespaces",
      "redshift-serverless:GetEndpointAccess",
      "redshift-serverless:ListEndpointAccess"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }

    condition {
      test     = var.project_name != null ? "StringEquals" : "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = var.project_name != null ? [var.project_name] : ["&{aws:PrincipalTag/${var.project_tag}}"]
    }
  }
}
