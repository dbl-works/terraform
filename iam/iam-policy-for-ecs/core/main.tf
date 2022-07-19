locals {
  # [
  #   {
  #       "name"        = "facebook-production"
  #       "env"         = "production"
  #     }
  #   },
  #   {
  #       "name"        = "facebook-staging"
  #       "env"         = "staging"
  #     }
  #   },
  #   {
  #       "name"        = "metaverse-staging"
  #       "env"         = "staging"
  #     }
  #   },
  # ]
  developer_access_projects = flatten([
    for env, project_names in try(var.project_access["developer"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env
      }
    ]
  ])

  admin_access_projects = flatten([
    for env, project_names in try(var.project_access["admin"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env
      }
    ]
  ])
}

# Taggable resources are only needed for admin full access
module "iam_ecs_taggable_resources" {
  source = "../taggable-resources"

  # define project.name as the key for tracking resources within Terraform
  for_each = { for project in merge(local.developer_access_projects, local.admin_access_projects) : project.name => project }

  region      = var.region
  environment = each.value.environment
  # If we already have the project_name, we can skip the project_tag
  project_name = each.value.name
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
  user       = var.username
  policy_arn = aws_iam_policy.ecs.arn
}
