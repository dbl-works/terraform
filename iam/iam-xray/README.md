# Terraform Module: IAM - XRay Access

You can test policies for IAM users: https://policysim.aws.amazon.com/home/index.jsp

This is its own module, since for a multi-region set up, X-Ray has to be created
in each region, while this policy is region independent.

This module creates the following groups:
* `xray-view`: Global read access to X-Ray resources


```terraform
module "xray_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-xray?ref=v2022.05.27"
}
```

## Usage

```terraform
# Define a list of users
locals {
  users = {
    testUser = {
      iam    = "test-user"
      name   = "Test User"
      groups = [
        "xray-view",
      ]
    }
  }
}


# Create an IAM user
resource "aws_iam_user" "user" {
  for_each = local.users
  name     = each.value["iam"]

  tags = {
    name   = each.value["name"]
}


# Assign groups to created user
resource "aws_iam_user_group_membership" "memberships" {
  for_each = local.users
  user     = each.value["iam"]
  groups   = each.value["groups"]
}
```
