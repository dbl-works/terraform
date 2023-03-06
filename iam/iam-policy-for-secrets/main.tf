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

data "aws_iam_policy_document" "secrets" {
  statement {
    sid = "AllowSecretAccess"
    actions = flatten([for resource in local.admin_resources : [
      "${resource}:*",
    ]])

    resources = concat(
      data.aws_secretsmanager_secret.app.*.arn,
      data.aws_secretsmanager_secret.terraform.*.arn
    )
  }
}


resource "aws_iam_policy" "secrets" {
  name        = "SecretAccessIn${title(var.region)}For${title(var.username)}"
  path        = "/"
  description = "Allow access to secrets based on project"

  policy = data.aws_iam_policy_document.secrets.json
}
