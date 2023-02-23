# Terraform Module: Lambda

Used for managing lambda functions.


## Usage

```terraform
module "lambda" {
  source = "github.com/dbl-works/terraform//lambda?ref=main"

  project         = "dbl"
  environment     = "production"

  source_dir = "Path to the directory containing the lambda function code."

  # optional
  handler = "index.handler"

  # Subnets the lambdas are allowed to use to access resources in the VPC.
  subnet_ids = [
    "subnet-123",
    "subnet-456",
  ]

  # To allow or deny specific access to resources in the VPC.
  security_group_ids = [
    module.rds.database_security_group_id, # e.g. for accessing the DB
    "sg-456",                              # any other security group
  ]

  # [optional] Grant access to the lambda function to Secrets and KMS keys
  secrets_and_kms_arns = [
    "arn:aws:secrets:*:abc:123",
  ]
}
```
