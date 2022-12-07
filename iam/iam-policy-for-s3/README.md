# Terraform Module: IAM - S3

User based S3 policy

This policy assumes the user have the following tags

- 'developer' grant read access, 'admin' grant write access to the following S3 buckets:
  - `<project>-<environment>-storage`

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

module "iam_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-s3?ref=v2022.05.18"

  project_access = local.users["gh-user"]["project_access"]
  username       = local.users["gh-user"]["iam"]

  # optional
  allow_listing_s3 = true # for the S3 index page on the UI, you need to allow listing all (excludes viewing the content)
}
```
