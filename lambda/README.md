# Terraform Module: Lambda

Used for managing lambda functions.


## Usage

```terraform
module "lambda" {
  vpc_id          = "vpc-123"
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
    "sg-123",
    "sg-456",
  ]

  # [optional] Grant access to the lambda function to Secrets and KMS keys
  secrets_and_kms_arns = [
    "arn:aws:secrets:*:abc:123",
  ]
}
```
