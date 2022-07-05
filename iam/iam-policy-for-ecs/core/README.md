# Terraform Module: IAM - S3

User based ECS policy

This policy assumes the user have the following tags

- staging-developer-access-projects
- staging-admin-access-projects
- production-developer-access-projects
- production-admin-access-projects

## Usage

```terraform
locals {
  users = {
    gh-user = {
      iam    = "gh-user"
      github = "user"
      name   = "Mary Lamb"
      groups = ["engineer"]
      staging-developer-access-projects    = "metaverse:messenger"
      staging-admin-access-projects        = "metaverse"
      production-developer-access-projects = "metaverse:facebook"
      production-admin-access-projects     = ""
    }
  }
}

resource "aws_iam_user" "user" {
  for_each = local.users
  name     = each.value["iam"]
  tags = {
    name                                 = each.value["name"]
    github                               = each.value["github"]
    staging-developer-access-projects    = try(each.value["staging-developer-access-projects"], "")
    staging-admin-access-projects        = try(each.value["staging-admin-access-projects"], "")
    production-developer-access-projects = try(each.value["production-developer-access-projects"], "")
    production-admin-access-projects     = try(each.value["production-admin-access-projects"], "")
  }
}

module "iam_ecs_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-ecs/core?ref=v2022.05.18"

  username = <iam-user-name>
  region   = "eu-central-1"

  projects = [
    {
      name        = "facebook",
      environment = "sandbox"
      region      = "eu-central-1"
      project_tag = "staging-admin-access-projects"
    },
    {
      name        = "facebook",
      environment = "load-testing"
      region      = "eu-central-1"
      project_tag = "staging-developer-access-projects"
    },
  ]

  # We need to get the latest state of the user before apply the policy
  depends_on = [
    aws_iam_user.user
  ]
}
```
