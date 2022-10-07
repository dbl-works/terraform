# Terraform Module: Fivetran lambda

Set up lambda connector in fivetran

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
module "lambda_connector" {
  source = "github.com/dbl-works/terraform//fivetran/connectors/lambda?ref=v2022.07.05"

  fivetran_group_id       = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  project                 = "meta" # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  environment             = "staging" # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)

  # optional
  aws_region_code         = "us-east-1" # lambda's aws region
  fivetran_aws_account_id = "834469178297" # Fivetran AWS account ID. We need to allow this account to access our lambda function.
  lambda_role_arn         = "arn:aws:iam::123456789:role/fivetran_lambda" # Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created.
  lambda_role_name        = "fivetran_lambda" # Lambda role name if you already have the role created
  policy_arns_for_lambda  = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]
  lambda_source_dir       = "${path.module}/tracker"
  lambda_output_path      = "${path.module}/dist/tracker.zip"
  service_name            = "lambda" # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  connector_name          = "lambda_meta_staging_eu-central" # connector name shown on Fivetran UI. If not specified, it will be the combination of (service_name)_(project)_(env)_(aws_region_code)
  script_env              = {
    RESOURCES_DATA: [{
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
   }]
  }
}
```

### Multi Region Setup:
For a multi-region deploy, omit the `lambda_role_arn` for one region, get the output for that role ARN, and re-use the same role ARN for all other regions.

You can define multiple AWS regions to keep all connectors in one workspace:

```terraform
output { value = module.metrics.lambda_role_arn }

local { lambda_role_arn = "arn:aws:iam::123:role/fivetran_lambda_xxx" }

# add "aws.us_east" under `configuration_aliases` in the terraform/aws block
provider "aws" {
  alias   = "us_east"
  profile = "squake-earth"
  region  = "us-east-1"
}

module "metrics-us-east" {
  source = "github.com/dbl-works/terraform//cloudwatch-snowflake"
  providers = { aws = aws.us_east }

  lambda_role_arn = local.lambda_role_arn
}
```

You'll also have to adjust the lambda javascript files for now, see [Issue 134](https://github.com/dbl-works/terraform/issues/134).
