# Terraform Module: Stack

This is our stack convention which brings all modules together, including:

- RDS (Postgres DB)
- ECS
  - Compute cluster for hosting docker based apps.
- Elasticache
  - Fully managed, in-memory caching service
- KMS
  - Encryption keys for securing various AWS resources (eg. Secrets Manager, RDS, S3)
- NAT (network address translation)
- S3 buckets (private & public)
- Secrets Manager
- VPC

## Getting Started

1. Refer to the [stack/setup module](stack/setup/README.md) on the pre-setup of stack modules
2. Add the following block to your terraform configurations

```terraform
module "stack" {
  source = "github.com/dbl-works/terraform//stack/app?ref=v2022.05.18"

  account_id         = "12345678"
  project            = "someproject"
  environment        = "staging"

  # Certificate manager
  domain_name = "my-domain.com"

  # VPC
  vpc_availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  # NAT -> you get these from the set-up
  public_ips = [
    "123.123.123.123",
    "234.234.234.234",
    "134.134.134.134",
  ]

  # Optional
  region          = "eu-central-1"
  skip_cloudflare = false

  # S3 Private
  private_buckets_list = [
    {
      bucket_name                     = "project-staging-apps",
      versioning                      = true,
      primary_storage_class_retention = 0,
      replicas                        = [
        {
          id         = "${project}-${environment}-storage-us-east-1"
          bucket_arn = "arn:aws:s3:::${project}-${environment}-storage-us-east-1"
          kms_arn    = "arn:aws:kms:us-east-1:${account_id}:key/${key_id}"
          region     = "us-east-1"
        }
      ]
    },
    {
      bucket_name = "project-staging-reports",
      versioning = false,
      primary_storage_class_retention = 10
    }
  ]

  # S3 Public
  public_buckets_list = [
    {
      bucket_name                     = "project-staging-media",
      versioning                      = true,
      primary_storage_class_retention = 0,
      replicas                        = []
    },
  ]

  # KMS
  kms_app_arn                 = "" # output from stack/setup
  kms_deletion_window_in_days = 30

  # RDS
  rds_instance_class     = "db.t3.micro"
  rds_engine_version     = "13"
  rds_allocated_storage  = 100

  ## set these, if you want to create a read-replica instead of a master DB
  ## the master-instance-arn MUST be the ARN of the DB, if the master DB is in
  ## another region. Otherwise, the instance-identifier may be used.
  ## Will create a VPC Peering Resource to allow connections to the master DB;
  ## This stack is the requester, the stack with the main DB is the accepter.
  ## The master-DB KMS key arn must be passed to allow decrypting the master DB.
  rds_is_read_replica               = false
  rds_master_db_instance_arn        = null
  rds_master_db_region              = null
  rds_master_db_vpc_id              = null
  rds_master_db_vpc_cidr_block      = null
  rds_master_db_kms_key_arn         = null
  rds_name                          = null # unique name, shouldn't be necessary if "regional" is set to true
  rds_multi_region_kms_key          = false # set to true for the MASTER stack, so that replicas can create a replica of the key
  rds_allow_from_cidr_blocks        = [] # non-master regions must be granted access to RDS by passing their CIDR block ( vpc-peering enabled! )
  rds_master_nat_route_table_ids    = [] # for the peering connection

  # ECS
  allow_internal_traffic_to_ports = []
  allowlisted_ssh_ips             = []
  grant_read_access_to_s3_arns    = []
  grant_write_access_to_s3_arns   = []
  grant_read_access_to_sqs_arns   = []
  grant_write_access_to_sqs_arns  = []
  ecs_custom_policies             = []
  # This is only needed when we want to add additional secrets to the ECS
  secret_arns                     = []
  # appends region to the name (usually ${project}-${environment}) for globally unique names
  regional                        = true
  enable_xray                     = false
  ecs_name                        = null # custom name when convention exceeds 32 chars
  autoscale_metrics_map = {
    web = {
      ecs_min_count = 2 # Optional, default value is 1
      ecs_max_count = 4 # Optional, default value is 30
      metrics = [
        {
          metric_name    = "CPUUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        },
        {
          metric_name    = "MemoryUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        }
      ]
    },
    sidekiq = {
      ecs_max_count = 4
      metrics = [
        {
          metric_name    = "CPUUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        },
        {
          metric_name    = "MemoryUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        }
      ]
    }
  }
  autoscale_params = {
    alarm_evaluation_periods      = 5
    alarm_period                  = 60  # seconds
    datapoints_to_alarm_up        = 3
    datapoints_to_alarm_down      = 3
    cooldown                      = 300 # seconds
    scale_up_adjustment           = 1
    scale_up_lower_bound          = 0
    scale_down_adjustment         = -1
    scale_down_upper_bound        = 0
    ecs_autoscale_role_arn        = "arn:aws:iam::123456789:role/ecs-autoscale"
    sns_topic_arn                 = "arn:aws:sns:us-east-1:175743622168:slack-sns"
    scale_down_treat_missing_data = "breaching"
    scale_up_treat_missing_data   = "missing"
  }

  # Cloudwatch
  cloudwatch_dashboard_view       = "detailed" # default is simple
  metric_period                   = 60
  alarm_period                    = 120
  alarm_evaluation_periods        = 1
  datapoints_to_alarm             = 2
  cloudwatch_sns_topic_arns       = "arn:aws:sns:eu-central-1:1XXXXXXXXXXX:first-sns-topic" # Required if user want to enable slack notification and has setup slack configuration once, sns_topic_arn can be retrieved from the output in the first time setup
  cloudwatch_custom_metrics       = []
  cloudwatch_elasticache_names    = []
  cloudwatch_database_identifiers = []
  cloudwatch_alb_arn_suffixes     = []
  cloudwatch_cluster_names        = []
  # https://aws.amazon.com/rds/instance-types/
  db_instance_class_memory_in_gb  = 1

  # Elasticache
  elasticache_node_type                     = "cache.t3.micro"
  elasticache_replicas_per_node_group       = 1
  elasticache_shards_per_replication_group  = 1
  elasticache_snapshot_retention_limit      = 0
  elasticache_parameter_group_name          = "default.redis6.x.cluster.on" # "default.redis6.x" for non-cluster mode
  elasticache_data_tiering_enabled          = false # see the README in the Elasticache Module
  elasticache_multi_az_enabled              = true

  # vpc
  vpc_cidr_block     = "10.0.0.0/16"
  vpc_peering        = false # automatically set to "true" if "rds_is_read_replica" is "true".
  remote_cidr_blocks = [] # for peering connections
}
```

```terraform
# output.tf

output "database_url" {
  value = module.stack.database_url
}

output "redis_url" {
  value = module.stack.redis_url
}

# Security groups and route tables, for linking with other resources
output "alb_security_group_id" {
  value = module.stack.alb_security_group_id
}
output "ecs_security_group_id" {
  value = module.stack.ecs_security_group_id
}

output "subnet_public_ids" {
  value = module.stack.subnet_public_ids
}

output "subnet_private_ids" {
  value = module.stack.subnet_private_ids
}

output "nat_route_table_ids" {
  value = module.stack.nat_route_table_ids
}

# Target groups, for use in deployments
output "alb_target_group_ecs_arn" {
  value = module.stack.alb_target_group_ecs_arn
}
output "nlb_target_group_ecs_arn" {
  value = module.stack.nlb_target_group_ecs_arn
}

# When launching a stack with a read replica
output "accept_status-requester" {
  value = module.stack.accept_status-requester
}

output "accept_status-accepter" {
  value = module.stack.accept_status-accepter
}

output "rds_kms_key_arn" {
  value = module.stack.rds_kms_key_arn
}
```


3. Add the following terraform output to the AWS secret manager
- redis_url
- database_url
