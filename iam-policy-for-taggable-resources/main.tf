data "aws_iam_policy_document" "taggable_resources" {
  source_policy_documents = [
    data.aws_iam_policy_document.admin.json,
    data.aws_iam_policy_document.developer.json,
    data.aws_iam_policy_document.deny_invalid_env_developer_access.json,
    data.aws_iam_policy_document.deny_invalid_project_developer_access.json,
  ]
}

resource "aws_iam_policy" "taggable_resources" {
  name        = "TaggableResourcesAccessOn${title(var.environment)}"
  path        = "/"
  description = "Allow access to taggable resources based on project on ${var.environment}"

  policy = data.aws_iam_policy_document.taggable_resources.json
}
