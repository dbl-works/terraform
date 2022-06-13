# Terraform Module: IAM - Attribute-based access control

IAM authorization strategy that defines permissions based on AWS tags - project and environment

This only need to applied once in the organization level

## Usage

```terraform
locals {
  users = {
    gh-user = {
      iam    = "gh-user"
      github = "user"
      name   = "Mary Lamb"
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

resource "aws_iam_group" "engineer" {
  name = "engineer"
  path = "/"
}

resource "aws_iam_user_group_membership" "memberships" {
  for_each = local.users
  user     = each.value["iam"]
  groups   = each.value["groups"]
  depends_on = [
    aws_iam_group.engineer,
  ]
}

locals {
  environments = ["staging", "production"]
}

module "iam_policies" {
  count  = length(local.environments)
  source = "github.com/dbl-works/terraform//iam-policy-for-taggable-resources?ref=v2021.07.05"

  # Required
  environment = local.environments[count.index]
}

resource "aws_iam_group_policy_attachment" "engineer" {
  count      = length(module.iam_policies.*.policy_arn)
  group      = aws_iam_group.engineer.name
  policy_arn = module.iam_policies.*.policy_arn[count.index]
}
```
