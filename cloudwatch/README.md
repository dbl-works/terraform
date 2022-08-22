# Terraform Module: Cloudwatch

Create a cloudwatch dashboard that consist of the following resources' metrics:
1. ECS Cluster
2. Database
3. Elasticache

## Usage

```terraform
module "cloudwatch" {
  source = "github.com/dbl-works/terraform//cloudwatch?ref=v2021.07.05"

  # Required
  region                         = "eu-central-1"
  project                        = "facebook"
  environment                    = "production"
  cluster_names                  = ["project-cluster"]
  database_identifiers           = ["project-database"]
  alb_arn_suffixes               = ["app/project/123456789"]
  elasticache_cluster_names      = ["project-elasticache"]
  # https://aws.amazon.com/rds/instance-types/
  db_instance_class_memory_in_gb = 1
  db_allocated_storage_in_gb     = 100

  # optional
  custom_metrics           = [
    {
      "height" : 4,
      "width" : 4,
      "type" : "metric",
      "properties" : {
        "title" : "Average Response Time",
        "view" : "singleValue",
        "sparkline" : true,
        "metrics" : [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/project/123456789", { "label" : "app/project/123456789" }]
        ],
        "region" : "eu-central-1"
      }
    }
  ]
  dashboard_name           = "facebook"
  metric_period            = 60
  alarm_period             = 120
  alarm_evaluation_periods = 1

  sns_topic_arns           = ["arn:aws:sns:eu-central-1:1XXXXXXXXXXX:first-sns-topic"] # Required if user want to publish message to the SNS when alarm is in alarm state
}
```
