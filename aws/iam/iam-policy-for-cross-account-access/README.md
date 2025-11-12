# Terraform Module: IAM Policy for Cross Account Access

By setting up cross-account access in this way, user don't have to create individual IAM users in each account.
In addition, users don't have to sign out of one account and sign in to another account to access resources in different AWS accounts.

## Usage

### In destination account
#### Account 1: Admin Access
```terraform
module "iam_cross_account_policies" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-cross-account-access/destination-account?ref=main"

  origin_aws_account_id = "xxxxxxxxxxxxxx"
  policy_name = "AdministratorAccess"

  # Optional
  max_session_duration = 4000 # in seconds
  aws_role_name = "assume-role-developer"
}
```

#### Account 2: Developer Access
```terraform
module "iam_cross_account_policies" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-cross-account-access/destination-account?ref=main"

  origin_aws_account_id = "yyyyyyyyyyyyyy"
  policy_name = "DeveloperAccess" # Prepare a policy named DeveloperAccess with the relevant access rights

  # Optional
  max_session_duration = 4000 # in seconds
  aws_role_name = "assume-role-admin"
}
```

### In origin account
```terraform
locals {
  aws_accounts = {
    chatgpt  = "xxxxxxxxxxxx"
    facebook = "xxxxxxxxxxxx"
    google   = "xxxxxxxxxxxx"
  }
}

module "iam_cross_account_policies" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-cross-account-access/origin-account?ref=main"
  for_each = local.aws_accounts

  usernames = ["muthu", "ali"]
  destination_aws_account_id = each.value
  destination_iam_role_name = "assume-role-admin"
}

module "iam_cross_account_policies_developer" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-cross-account-access/origin-account?ref=main"

  usernames = ["muthu"]
  destination_aws_account_id = "yyyyyyyyyyyyy"
  destination_iam_role_name = "assume-role-developer"
}
```
