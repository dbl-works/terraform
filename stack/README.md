# Terraform Module: Stack

This is our stack convention which brings all modules together, including:

- AWS Certificate Manager
- RDS (Postgres DB)
- ECR
  - Storing built docker images.
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

```terraform
module "stack" {
  source = "github.com/dbl-works/terraform//stack?ref=v2022.05.18"

  account_id         = "12345678"
  project            = "someproject"
  environment        = "staging"

  # certificate manager
  domain_name = "my-domain.com"

  # VPC
  vpc_availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  # NAT
  public_ips = [
    "123.123.123.123",
    "234.234.234.234",
    "134.134.134.134",
  ]

  # S3 Private
  private_buckets_list = [
    {
      bucket_name = "project-staging-apps",
      versioning = true,
      primary_storage_class_retention = 0,
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
      bucket_name = "project-staging-media",
      versioning = true,
      primary_storage_class_retention = 0,
    },
  ]

  # Optional
  region     = "eu-central-1"

  # certificate manager
  add_wildcard_subdomains = true

  # ECR
  mutable_ecr = false

  # KMS
  kms_deletion_window_in_days = 30

  # RDS
  rds_instance_class     = "db.t3.micro"
  rds_engine_version     = "13.2"
  rds_allocated_storage  = 100

  # ECS
  allow_internal_traffic_to_ports = []
  allowlisted_ssh_ips = []
  grant_read_access_to_s3_arns = []
  grant_write_access_to_s3_arns = []
  grant_read_access_to_sqs_arns  = []
  grant_write_access_to_sqs_arns = []
  ecs_custom_policies = []

  # Elasticache
  elasticache_node_count = 1
  elasticache_node_type  = "cache.t3.micro"

  # vpc
  vpc_cidr_block = "10.0.0.0/16"
}
```

## NOTES

1. To populate secrets to the secret manager, user need to prepare 2 json files
   - app-secrets.json (Used by the ecs)
   - terraform-secrets.json (Used in the terraform setup)
