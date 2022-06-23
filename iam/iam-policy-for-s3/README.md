# Terraform Module: IAM - S3

User based S3 policy

This policy assumes the user have the following tags

- staging-developer-access-projects
- staging-admin-access-projects
- production-developer-access-projects
- production-admin-access-projects

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

module "iam_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-s3?ref=v2022.05.18"
  username = <iam-user-name>
}
```
