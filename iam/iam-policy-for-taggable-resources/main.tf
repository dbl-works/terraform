data "aws_iam_policy_document" "taggable_resources" {
  source_policy_documents = [
    # ======== Admin Access ======== #
    data.aws_iam_policy_document.admin.json,
    # ======== Developer Access ======== #
    data.aws_iam_policy_document.developer.json,
  ]
}

resource "aws_iam_policy" "taggable_resources" {
  name        = "TaggableResourcesAccessOn${title(var.environment)}"
  path        = "/"
  description = "Allow access to taggable resources based on project on ${var.environment}"

  policy = data.aws_iam_policy_document.taggable_resources.json
}
