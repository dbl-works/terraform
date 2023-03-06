data "aws_secretsmanager_secret" "app" {
  for_each = {
    for project in local.admin_access_projects : "${project.name}-${project.environment}" => project
  }

  name = "${each.value.name}/app/${each.value.environment}"
}

data "aws_secretsmanager_secret" "terraform" {
  for_each = {
    for project in local.admin_access_projects : "${project.name}-${project.environment}" => project
  }

  name = "${each.value.name}/app/${each.value.environment}"
}

data "aws_kms_key" "secrets" {
  for_each = local.kms_ids

  key_id = each.key
}

data "aws_iam_policy_document" "secrets" {
  statement {
    sid = "AllowSecretAccess"
    actions = flatten([for resource in local.admin_resources : [
      "${resource}:*",
    ]])

    resources = length(local.secretmanager_arns) > 0 ? concat(local.secretmanager_arns, values(data.aws_kms_key.secrets[*]).arn) : ["arn:aws:secretsmanager:*:secret:can-t-be-blank"]
  }
}

resource "aws_iam_policy" "secrets" {
  name        = "SecretAccessIn${title(var.region)}For${title(var.username)}"
  path        = "/"
  description = "Allow access to secrets based on project"

  policy = data.aws_iam_policy_document.secrets.json
}
