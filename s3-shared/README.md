# Terraform Module: s3-shared

Sets up a private S3 bucket with full access by the host-account, and read/write only access for a guest-account.

## Usage

```terraform
module "s3-shared-client_A" {
  source = "github.com/dbl-works/terraform//s3-shared?ref=v2024.01.31"

  environment        = "staging"
  project            = "someproject"
  guest_account_id   = "123abc"
}
```

Outputs:
* `id`
* `bucket_name`
* `arn`

pass the S3 bucket ARN to the ECS module to grant access to it for the apps

```terraform
module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.

  grant_read_access_to_s3_arns  = [
    module.s3-shared-client_A.arn
  ]

  grant_write_access_to_s3_arns = [
    module.s3-shared-client_A.arn
  ]
}
```
