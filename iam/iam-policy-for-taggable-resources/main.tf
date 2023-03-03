data "aws_iam_policy_document" "taggable_resources" {
  source_policy_documents = [
    # ======== Admin Access ======== #
    data.aws_iam_policy_document.admin.json,
    data.aws_iam_policy_document.secret_manager.json,
    # ======== Developer Access ======== #
    data.aws_iam_policy_document.developer.json,

    # This policy grants all the members in the group read access
    # to the list of resources specified in the locals.tf
    data.aws_iam_policy_document.read_access.json,
  ]
}

resource "aws_iam_policy" "taggable_resources" {
  name        = "TaggableResourcesAccessOn${title(var.environment)}"
  path        = "/"
  description = "Allow access to taggable resources based on project on ${var.environment}"

  policy = data.aws_iam_policy_document.taggable_resources.json
}
