locals {
  admin_resources = [
    "kms",
    "secretsmanager",
  ]

  admin_access_projects = flatten([
    for env, project_names in try(var.project_access["admin"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env
      }
    ]
  ])
}
