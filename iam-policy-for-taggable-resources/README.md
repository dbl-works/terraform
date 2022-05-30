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
      staging-developer-access-projects    = "metaverse"
      staging-admin-access-projects        = "metaverse"
      production-developer-access-projects = "metaverse"
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
    staging-developer-access-projects    = each.value["staging-developer-access-projects"]
    staging-admin-access-projects        = each.value["staging-admin-access-projects"]
    production-developer-access-projects = each.value["production-developer-access-projects"]
    production-admin-access-projects     = each.value["production-admin-access-projects"]
  }
}

module "organization_level_iam_policy" {
  source = "github.com/dbl-works/terraform//iam-policy-for-taggable-resources?ref=v2021.07.05"

  # Required
  environment = "staging"
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  for_each = aws_iam_user.user

  user       = each.value.name
  policy_arn = module.organization_level_iam_policy.policy_arn
}

```
