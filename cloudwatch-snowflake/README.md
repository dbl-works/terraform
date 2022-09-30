# Terraform Module: Cloudwatch Snowflake

Syncing the following Cloudwatch metrics to Snowflake table thru Fivetran:

- CPUUtilization
- MemoryUtilization
- TargetResponseTime (p50, p90, p99)
- 5xx Error Count

Lambda is used to send cloudwatch metrics to fivetran from AWS every 60 minutes.
It is created automatically thru the script.

```
module "metrics" {
  source = "github.com/dbl-works/terraform//cloudwatch-snowflake"

  fivetran_api_key    = XXXXXXXXXXX
  fivetran_api_secret = YYYYYYYYYY
  fivetran_group_id   = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  organisation        = "meta" # connector name shown on Fivetran UI, i.e. cloudwatch_metrics_(organisation)_eu_central_1
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

  # optional
  aws_region_code = "us-east-1" # lambda's aws region
  fivetran_aws_account_id = "834469178297" # Fivetran AWS account ID. We need to allow this account to access our lambda function.
  lambda_role_arn  = "arn:aws:iam::123456789:role/fivetran_lambda" # Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created.
}
```
