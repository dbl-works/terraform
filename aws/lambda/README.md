# Terraform Module: Lambda

Used for managing lambda functions.

## Usage

```terraform
module "lambda" {
  source = "github.com/dbl-works/terraform//lambda?ref=main"

  function_name   = "lambda"
  project         = "dbl"
  environment     = "production"
  source_dir      = "Path to the directory containing the lambda function code."

  # optional
  handler     = "index.handler"
  timeout     = 10
  memory_size = 1024
  runtime     = "nodejs20.x" # https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime

  # Subnets the lambdas are allowed to use to access resources in the VPC.
  subnet_ids = [
    "subnet-123",
    "subnet-456",
  ]

  # You can get the list of available lambda layers here
  # https://github.com/keithrozario/Klayers
  aws_lambda_layer_arns = [
    "arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-p39-psycopg2-binary:1"
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

  lambda_policy_json = data.aws_iam_policy_document.s3.json
  environment_variables = {
    foo = "bar"
  }
  lambda_role_name = "aws-lambda-role"
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

```
