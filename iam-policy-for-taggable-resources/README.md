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
    staging-developer-access-projects    = each.value["staging-developer-access-projects"]
    staging-admin-access-projects        = each.value["staging-admin-access-projects"]
    production-developer-access-projects = each.value["production-developer-access-projects"]
    production-admin-access-projects     = each.value["production-admin-access-projects"]
  }
}

locals {
  environments = ["staging", "production"]
}

module "iam_policies" {
  count  = length(local.environments)
  source = "../iam-policy-for-taggable-resources"

  # Required
  environment = local.environments[count.index]
}


resource "aws_iam_user_policy_attachment" "staging" {
  for_each = aws_iam_user.user

  user       = each.value.name
  policy_arn = module.iam_policies[0].policy_arn
}

resource "aws_iam_user_policy_attachment" "production" {
  for_each = aws_iam_user.user

  user       = each.value.name
  policy_arn = module.iam_policies[1].policy_arn
}

```
