# Terraform Module: Cloudwatch Snowflake

Syncing the following Cloudwatch metrics to Snowflake table thru Fivetran:

- CPUUtilization
- MemoryUtilization
- TargetResponseTime (p50, p90, p99)
- 5xx Error Count

```
module "metrics" {
  source = "github.com/dbl-works/terraform//cloudwatch-snowflake"

  fivetran_group_id = "fivetran-group-id"
  organisation = "meta"
  fivetran_api_key = XXXXXXXXXXX
  fivetran_api_secret = YYYYYYYYYY
  tracked_resources_data = [
    {
      projectName      = "facebook"
      serviceName      = "web",
      clusterName      = "facebook-production"
      loadBalancerName = "app/facebook-production/7ed111aa2bf1de37"
      environment      = "production"
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
  aws_region_code = "us-east-1"
  fivetran_aws_account_id = "834469178297"
  lambda_role_arn  = "arn:aws:iam::123456789:role/fivetran_lambda"
}
```
