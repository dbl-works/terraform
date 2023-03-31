# Terraform Module: IAM Policy for Cross Account Access

By setting up cross-account access in this way, user don't have to create individual IAM users in each account.
In addition, users don't have to sign out of one account and sign in to another account to access resources in different AWS accounts.

## Usage

### In destination account
```terraform
module "iam_cross_account_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-cross-account-access/destination-account?ref=main"

  aws_account_id = "xxxxxxxxxxxxxx"
  policy_name = "AdministratorAccess"

  # Optional
  max_session_duration = 4000 # in seconds
}
```

### In bastion account
```terraform
module "iam_cross_account_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-cross-account-access/bastion-account?ref=main"

  username = "muthu"
  destination_aws_account_id = "xxxxxxxxxxxxx"
  destination_iam_role_name = "assume-role-12345667878-admin"
}
```
