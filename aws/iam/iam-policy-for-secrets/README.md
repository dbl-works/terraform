# Terraform Module: Secrets

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
        admin = {
          staging = [
            "amazon",
          ]
          production = [
            "facebook",
          ]
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
  }
}

module "iam_secrets_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-secrets?ref=v2022.12.12"

  for_each = local.users

  username       = each.value["iam"]
  project_access = each.value["project_access"]
  region         = "eu-central-1"
}
```
