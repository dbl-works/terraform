data "aws_iam_user" "main" {
  user_name = var.username
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
      for name in local.staging_read_access_project_list : "${name}-staging"
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
# TODO: To avoid the policy exceed the characters count,
# This should be moved to the taggable resources modules
# TODO: Make this a loop for all the availability region
module "iam_ecs_taggable_resources_in_staging" {
  source = "../taggable-resources"

  region      = var.region
  environment = "staging"
  project_tag = "staging-admin-access-projects"
}

module "iam_ecs_taggable_resources_in_production" {
  source = "../taggable-resources"

  region      = var.region
  environment = "production"
  project_tag = "production-admin-access-projects"
}

# TODO: Add some other policies based on project and staging
data "aws_iam_policy_document" "ecs_list" {
  # statement {
  #   sid = "AllowListAccessToECS"
  #   actions = [
  #     "ecs:DescribeClusters",
  #     "ecs:ListClusters"
  #   ]
  #   resources = ["*"]
  # }

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
  source_policy_documents = concat(
    [
      # All user should have list access so they can see the index page
      data.aws_iam_policy_document.ecs_list.json,
      data.aws_iam_policy_document.ecs_iam,
      data.aws_iam_policy_document.ecs_ssm,

      # module.iam_ecs_taggable_resources_in_staging.ecs_taggable_resources_policy,
      # module.iam_ecs_taggable_resources_in_production.ecs_taggable_resources_policy,
      # This might throw error
      module.iam_ecs_read_access.ecs_read_policy,
      module.iam_ecs_full_access.ecs_full_policy
    ]
  )
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

output "ecs_read_policy" {
  value = module.iam_ecs_read_access.ecs_read_policy
}

output "read_access_project_names" {
  value = local.read_access_project_names
}

output "full_access_project_names" {
  value = local.full_access_project_names
}
