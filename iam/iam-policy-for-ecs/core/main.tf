# var.user
# var.user["project_access"]

locals {
  read_access_environments  = keys(var.user["project_access"]["developer"])                      # ["staging", "production"]
  read_access_project_names = distinct(flatten(values(var.user["project_access"]["developer"]))) # ["facebook-staging", "metaverse-staging", "facebook-production"]
}

locals {
  staging_developer_access_projects    = try(data.aws_iam_user.main.tags.staging-developer-access-projects, "")
  staging_admin_access_projects        = try(data.aws_iam_user.main.tags.staging-admin-access-projects, "")
  production_developer_access_projects = try(data.aws_iam_user.main.tags.production-developer-access-projects, "")
  production_admin_access_projects     = try(data.aws_iam_user.main.tags.production-admin-access-projects, "")

  staging_read_access_project_list    = distinct(compact(split(":", local.staging_developer_access_projects)))
  production_read_access_project_list = distinct(compact(split(":", local.production_admin_access_projects)))
  staging_full_access_project_list    = distinct(compact(split(":", local.staging_admin_access_projects)))
  production_full_access_project_list = distinct(compact(split(":", local.production_admin_access_projects)))

  read_access_project_names = concat(
    [
      for name in local.staging_read_access_project_list : "${name}-staging" # ["facebook-staging"]
    ],
    [
      for name in local.production_read_access_project_list : "${name}-production"
    ]
  )

  full_access_project_names = concat(
    [
      for name in local.staging_full_access_project_list : "${name}-staging"
    ],
    [
      for name in local.production_full_access_project_list : "${name}-production"
    ]
  )
}

# Taggable resources are only needed for admin full access
module "iam_ecs_taggable_resources" {
  source = "../taggable-resources"

  for_each = {
    for project in local.projects :
    "${project.environment}-${project.name != null ?
    "${project.name}" : "${project.project_tag}"}-${project.region}" => project
  }

  region       = each.value.region
  environment  = each.value.environment
  project_name = each.value.name
  project_tag  = lookup(each.value, "project_tag", null)
}

data "aws_iam_policy_document" "ecs_list" {
  statement {
    sid = "AllowListAccessToECS"
    actions = [
      "ecs:DescribeClusters",
      "ecs:ListClusters"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowListAccessToECSRelevantResources"
    actions = [
      "cloudwatch:*",
      "logs:Describe*",
      "logs:Get*",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_policy" {
  source_policy_documents = flatten(concat(
    [
      # All user should have list access so they can see the index page
      data.aws_iam_policy_document.ecs_list.json,
      length(local.read_access_project_names) > 0 ? [
        data.aws_iam_policy_document.ecs_read.json
      ] : [],

      length(local.full_access_project_names) > 0 ? [
        data.aws_iam_policy_document.ecs_iam.json,
        data.aws_iam_policy_document.ecs_ssm.json,
        data.aws_iam_policy_document.ecs_full.json
      ] : []
    ],
    [values(module.iam_ecs_taggable_resources)[*].policy_json]
  ))
}

resource "aws_iam_policy" "ecs" {
  name        = "ECSAccessFor${title(var.username)}"
  path        = "/"
  description = "Allow access to ECS resources for ${var.username}"

  policy = data.aws_iam_policy_document.ecs_policy.json
}

resource "aws_iam_user_policy_attachment" "user" {
  user       = data.aws_iam_user.main.user_name
  policy_arn = aws_iam_policy.ecs.arn
}
