# Terraform Module: Fivetran lambda

### Example
Set up lambda connector in fivetran which sync cloudwatch metrics

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    fivetran = {
      source  = "fivetran/fivetran"
      version = "~> 0.6.1"
    }
  }

  required_version = ">= 1.0"
}

variable "fivetran_api_key" {
  type = string
}

variable "fivetran_api_secret" {
  type = string
}

provider "fivetran" {
  api_key    = var.fivetran_api_key    # $ export TF_VAR_fivetran_api_key=<api-key>
  api_secret = var.fivetran_api_secret # $ export TF_VAR_fivetran_api_secret=<api-secret>
}
```

```
module "lambda_role" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-fivetran-lambda?ref=v2022.07.05"

  fivetran_group_id = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  fivetran_aws_account_id = "834469178297" # Fivetran AWS account ID. We need to allow this account to access our lambda function.
}

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  role       = module.lambda_role.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
```

```
locals {
  tracked_resources_data = [
    {
      serviceName      = "web",                 # ecs service name. eg. aws_ecs_service => name
      clusterName      = "facebook-production"  # ecs cluster name. eg. aws_ecs_cluster => name
      loadBalancerName = "app/facebook-production/7ed111aa2bf1de37" # load balancer arn suffix. eg. aws_lb => arn_suffix
      projectName      = "facebook"    # Do not include any special characters. This value will be passed into the snowflake table under the project column
      environment      = "production"  # Do not include any special characters. This value will be passed into the snowflake table under the environment column
    },
    {
      projectName      = "facebook"
      serviceName      = "web",
      clusterName      = "facebook-staging"
      loadBalancerName = "app/facebook-staging/a1c2a365faf11127"
      environment      = "staging"
    }
  ]
}

module "lambda_connector" {
  source = "github.com/dbl-works/terraform//fivetran/connectors/lambda?ref=v2022.07.05"
  providers = {
    # Have to specified the provider because fivetran is not from hashicorp
    fivetran = fivetran
  }

  fivetran_group_id       = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  project                 = "meta"              # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  environment             = "staging"           # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)

  # optional
  service_name            = "lambda"                           # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  aws_region_code         = "us-east-1"                        # lambda's aws region
  lambda_role_arn         = module.lambda_role.lambda_role_arn # Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created.
  lambda_source_dir       = "${path.module}/tracker"           # Add your lambda script to the tracker directory
  lambda_output_path      = "${path.module}/dist/tracker.zip"  # The location of the output path
  connector_name          = "lambda_meta_staging_eu-central"   # Optional. connector name shown on Fivetran UI. If not specified, it will be the combination of (service_name)_(project)_(env)_(aws_region_code)
  script_env              = {
    RESOURCES_DATA = jsonencode(local.tracked_resources_data)
    PERIOD         = "3600"
    AWS_REGION     = var.aws_region_code
  }
}
```
