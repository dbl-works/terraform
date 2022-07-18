locals {
  # [
  #   {
  #       "name"        = "facebook-production"
  #       "env"         = "production"
  #       "project_tag" = "production-developer-access-projects"
  #     }
  #   },
  #   {
  #       "name"        = "facebook-staging"
  #       "env"         = "staging"
  #       "project_tag" = "staging-developer-access-projects"
  #     }
  #   },
  #   {
  #       "name"        = "metaverse-staging"
  #       "env"         = "staging"
  #       "project_tag" = "staging-developer-access-projects"
  #     }
  #   },
  # ]
  developer_access_projects = flatten([
    for env, project_names in try(var.user["project_access"]["developer"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env,
        "project_tag" = "${env}-developer-access-projects"
      }
    ]
  ])

  admin_access_projects = flatten([
    for env, project_names in try(var.user["project_access"]["admin"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env,
        "project_tag" = "${env}-admin-access-projects"
      }
    ]
  ])
}


# Taggable resources are only needed for admin full access
module "iam_ecs_taggable_resources" {
  source = "../taggable-resources"

  for_each = [for project in concat(local.developer_access_projects, local.admin_access_projects) : {
    project["name"] = project
  }]

  region       = var.region
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
      length(local.developer_access_projects) > 0 ? [
        data.aws_iam_policy_document.ecs_read.json
      ] : [],

      length(local.admin_access_projects) > 0 ? [
        data.aws_iam_policy_document.ecs_iam.json,
        data.aws_iam_policy_document.ecs_ssm.json,
        data.aws_iam_policy_document.ecs_full.json
      ] : []
    ],
    [values(module.iam_ecs_taggable_resources)[*].policy_json]
  ))
}

resource "aws_iam_policy" "ecs" {
  name        = "ECSAccessIn${var.region}For${title(var.username)}"
  path        = "/"
  description = "Allow access to ECS resources in ${var.region} for ${var.username}"

  policy = data.aws_iam_policy_document.ecs_policy.json
}

resource "aws_iam_user_policy_attachment" "user" {
  user       = data.aws_iam_user.main.user_name
  policy_arn = aws_iam_policy.ecs.arn
}
