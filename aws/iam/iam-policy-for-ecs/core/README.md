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
      project_access = {
        developer = {
          staging        = ["facebook", "metaverse"]
          production     = ["facebook"]
          sandbox        = ["facebook", "metaverse"]
          loadtesting    = ["facebook", "metaverse"]
        }
        admin = {
          sandbox = ["facebook"]
        }
      }
    }
  }
}

resource "aws_iam_user" "user" {
  for_each = local.users
  name     = each.value["iam"]

  tags = {
    name                                 = each.value["name"]
    github                               = each.value["github"]

    staging-developer-access-projects    = join(":", try(each.value["developer"]["staging"], []))
    staging-admin-access-projects        = join(":", try(each.value["admin"]["staging"], []))
    production-developer-access-projects = join(":", try(each.value["developer"]["production"], []))
    production-admin-access-projects     = join(":", try(each.value["admin"]["production"], []))
    sandbox-admin-access-projects        = join(":", try(each.value["admin"]["sandbox"], []))
  }
}

module "iam_ecs_policies" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-ecs/core?ref=main"

  for_each = local.users

  username       = each.value["iam"]
  project_access = each.value["project_access"]
  region         = "eu-central-1"

  # optional
  allow_listing_ecs = true
}
```
