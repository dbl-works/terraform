# Terraform Module: Multi Stack

This is our stack convention which brings multiple projects together, including:

- Shared RDS (Postgres DB)
- Shared ECS cluster
- Shared Elasticache
- KMS
  - Encryption keys for various AWS resources (eg. Secret Manager, RDS, S3)
- S3 buckets (1 for each project)
- Secrets Managers (1 for each project, 1 for infra)
- Shared VPC

## Getting Started
```
module "multi-stack-setup" {
  source = "github.com/dbl-works/terraform//multi-stack/setup"

  environment = "staging"
  project     = "lih-shared"
  project_settings = {
    facebook = {
      domain = "facebook.com"
    }
  }

  # Optional
  add_wildcard_subdomains = true

  # KMS
  kms_deletion_window_in_days = 30
}
```

```
module "multi-stack" {
  source = "github.com/dbl-works/terraform//multi-stack/app"

  project     = "lih-shared"
  environment = "staging"
  region      = "eu-central-1"

  project_settings = {
    facebook = {
      domain = "facebook.com"
      host_header = [
        "api.facebook.com",
        "support.facebook.com"
      ]
      private_buckets_list = [
        "facebook-${local.environment}-storage-${local.region}"
      ]
      public_buckets_list = [
        "facebook-${local.environment}-public-${local.region}"
      ]
      s3_cloudflare_records = {
        app = {
          worker_script_name = "facebook-router"
        },
        cdn = {
          worker_script_name = "facebook-router"
        },
      }
    }
  }

  # KMS
  kms_deletion_window_in_days = 7

  # RDS
  rds_config = {
    instance_class    = "db.t3.micro"
    allocated_storage = 10
  }

  # ECS
  ecs_config = {
    allow_internal_traffic_to_ports = [5017]
    allowlisted_ssh_ips = [
      # local.master_vpn_ip,
    ]
    health_check_options = {
      matcher = "200,204,301,302"
    }
    vpc_cidr_block = local.cidr_block
    grant_write_access_to_s3_arns = [
      "arn:aws:s3:::facebook-${local.environment}-public-${local.region}"
    ]
  }


  # Elasticache
  elasticache_config = {
    replicas_per_node_group      = 1
    shards_per_replication_group = l1
    node_type                    = "cache.t4g.micro"
    snapshot_retention_limit     = 0
    multi_az_enabled             = false # Enable this only in production
    data_tiering_enabled         = false # Only worthy if we needs a lot of memory usage
    parameter_group_name         = null  # Set this to null explicitly to avoid the replacement of parameter group and possibly downtime
    maxmemory_policy             = "noeviction"
    # Use non-cluster mode for redis so we won't need second non-cluster-mode Redis for Sidekiq
    cluster_mode               = false
    automatic_failover_enabled = false
  }

  # VPC
  vpc_config = {
    cidr_block         = "10.1.0.0/16"
    remote_cidr_blocks = []
    availability_zones = [
      "eu-central-1a",
      "eu-central-1b",
      "eu-central-1c",
    ]
  }
}
```
