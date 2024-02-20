# Terraform Module: Cognito

Create user pools for use with authentication.



## Usage

```terraform
module "cognito" {
  source = "github.com/dbl-works/terraform//cognito?ref=v2021.07.05"

  project         = local.project
  environment     = local.environment
  region          = local.region
  ses_from_email  = "TODO"
  ses_arn         = "TODO"
}
```



## Outputs
- `aws_cognito_identity_pool_id`
- `aws_cognito_identity_pool_arn`
- `aws_exports_content`
