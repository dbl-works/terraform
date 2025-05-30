# Terraform Module: IAM Policy for Redshift Serverless - Taggable Resources

Tag-based IAM policy for Redshift Serverless access control.
Either project_name and project_tag needs to be present.

- When `project_name` is present, access will be given to the resources with `Project` tags equals to the `project_name` value
- When `project_tag` is present, access will be given to the resources with `Project` tags similar to that principal project tag

## Usage

```terraform
module "iam_redshift_serverless_taggable_resources" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-redshift-serverless/taggable-resources?ref=v2025.05.18"

  region       = "eu-central-1"
  environment  = "staging"

  # Optional
  project_name = "facebook"
  project_tag  = "staging-developer-access-projects"
}

output "policy_json" {
  value = module.iam_redshift_serverless_taggable_resources.policy_json
}
```

## Permissions Granted

This module grants the following permissions to Redshift Serverless resources with matching Project/Environment tags:

- `redshift-serverless:GetCredentials` - Get temporary database credentials for IAM authentication
- `redshift-serverless:GetWorkgroup` - View workgroup details
- `redshift-serverless:ListWorkgroups` - List available workgroups
- `redshift-serverless:GetNamespace` - View namespace details
- `redshift-serverless:ListNamespaces` - List available namespaces
- `redshift-serverless:GetEndpointAccess` - View endpoint access details
- `redshift-serverless:ListEndpointAccess` - List available endpoint accesses

These permissions allow users to connect to Redshift Serverless via bastion hosts using IAM authentication.
