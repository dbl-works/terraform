locals {
  admin_resources = [
    "kms",
    "secretsmanager",
  ]

  admin_access_projects = flatten([
    for env, project_names in try(var.project_access["admin"], {}) : [
      for project_name in project_names : {
        "name"        = project_name
        "environment" = env
      }
    ]
  ])

  secretmanager_and_kms_arns = concat(
    values(data.aws_secretsmanager_secret.app)[*].arn,
    values(data.aws_secretsmanager_secret.terraform)[*].arn,
    values(data.aws_secretsmanager_secret.app)[*].kms_key_id,
    values(data.aws_secretsmanager_secret.terraform)[*].kms_key_id,
  )
}
