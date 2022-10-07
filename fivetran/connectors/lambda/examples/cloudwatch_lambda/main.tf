locals {
  tracked_resources_data = [
    {
      serviceName      = "web",                                     # ecs service name. eg. aws_ecs_service => name
      clusterName      = "facebook-production"                      # ecs cluster name. eg. aws_ecs_cluster => name
      loadBalancerName = "app/facebook-production/7ed111aa2bf1de37" # load balancer arn suffix. eg. aws_lb => arn_suffix
      projectName      = "facebook"                                 # Do not include any special characters. This value will be passed into the snowflake table under the project column
      environment      = "production"                               # Do not include any special characters. This value will be passed into the snowflake table under the environment column
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
  source = "github.com/dbl-works/terraform//fivetran/connectors/lambda?ref=main"
  providers = {
    # Have to specified the provider because fivetran is not from hashicorp
    fivetran = fivetran
  }

  fivetran_group_id = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  project           = "meta"              # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  environment       = "staging"           # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)

  # optional
  service_name       = "lambda"                           # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  aws_region_code    = "us-east-1"                        # lambda's aws region
  lambda_role_arn    = module.lambda_role.lambda_role_arn # Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created.
  lambda_source_dir  = "${path.module}/tracker"           # Add your lambda script to the tracker directory
  lambda_output_path = "${path.module}/dist/tracker.zip"  # The location of the output path
  connector_name     = "lambda_meta_staging_eu-central"   # Optional. connector name shown on Fivetran UI. If not specified, it will be the combination of (service_name)_(project)_(env)_(aws_region_code)
  script_env = {
    RESOURCES_DATA = jsonencode(local.tracked_resources_data)
    PERIOD         = "3600"
    AWS_REGION     = "us-east-1"
  }
}
