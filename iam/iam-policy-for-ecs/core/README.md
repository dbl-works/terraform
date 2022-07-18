# Terraform Module: IAM Policy for ECS - Core

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
      developer_access = {
        staging        = ["facebook", "metaverse"]
        production     = ["facebook"]
        sandbox        = ["facebook", "metaverse"]
        loadtesting    = ["facebook", "metaverse"]
      }
      admin_access = {
        sandbox = ["facebook"]
      }


      # staging-developer-access-projects    = "metaverse:messenger"
      # staging-admin-access-projects        = "metaverse"
      # production-developer-access-projects = "metaverse:facebook"
      # production-admin-access-projects     = ""
    }
  }
}

resource "aws_iam_user" "user" {
  for_each = local.users
  name     = each.value["iam"]
  tags = {
    name                                 = each.value["name"]
    github                               = each.value["github"]
    # staging-developer-access-projects    = try(each.value["staging-developer-access-projects"], "")
    # staging-admin-access-projects        = try(each.value["staging-admin-access-projects"], "")
    # production-developer-access-projects = try(each.value["production-developer-access-projects"], "")
    # production-admin-access-projects     = try(each.value["production-admin-access-projects"], "")


    admin-sandbox-access-projects        = join(":", try(each.value["admin_access"]["sandbox"], []))
    admin-staging-access-projects        = join(":", try(each.value["admin_access"]["staging"], []))
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
    },
    {
      name        = "facebook",
      environment = "load-testing"
      region      = "eu-central-1"
    },
  ]

  # We need to get the latest state of the user before apply the policy
  depends_on = [
    aws_iam_user.user
  ]
}
```
