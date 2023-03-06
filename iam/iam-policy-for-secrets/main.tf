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
  count = length(local.kms_ids)

  key_id = local.kms_ids[count.index]
}

data "aws_iam_policy_document" "secrets" {
  statement {
    sid = "AllowSecretAccess"
    actions = flatten([for resource in local.admin_resources : [
      "${resource}:*",
    ]])

    resources = length(local.secretmanager_arns) > 0 ? concat(local.secretmanager_arns, data.aws_kms_key.secrets[*].arn) : ["arn:aws:secretsmanager:*:secret:can-t-be-blank"]
  }
}

resource "aws_iam_policy" "secrets" {
  name        = replace("SecretAccessIn${title(var.region)}For${title(var.username)}", "/[^0-9A-Za-z]/", "")
  path        = "/"
  description = "Allow access to secrets based on project"

  policy = data.aws_iam_policy_document.secrets.json
}

resource "aws_iam_user_policy_attachment" "secrets" {
  user       = var.username
  policy_arn = aws_iam_policy.secrets.arn
}
