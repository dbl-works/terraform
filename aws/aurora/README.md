# Aurora PostgreSQL

This module creates an Amazon Aurora PostgreSQL cluster with support for zero-ETL integration with Amazon Redshift.

## Features

- **Aurora PostgreSQL** cluster with configurable number of instances
- **Zero-ETL Integration** support with logical replication parameters
- **IAM Database Authentication** enabled with pre-configured groups and policies
- **Enhanced Monitoring** with CloudWatch integration
- **Performance Insights** enabled
- **Encryption** at rest and in transit
- **Backup and Snapshot** management
- **Security Groups** with configurable access rules

## Differences from RDS Module

Aurora is a cloud-native database service that differs from traditional RDS:

- **Cluster Architecture**: Aurora uses a cluster with multiple instances (writer/reader)
- **Storage**: Aurora uses a distributed, fault-tolerant storage system
- **Scaling**: Aurora can scale read capacity by adding reader instances
- **Zero-ETL**: Aurora PostgreSQL supports zero-ETL integration with Redshift
- **Performance**: Generally better performance than traditional RDS

## Usage

### Basic Usage

```terraform
module "aurora" {
  source = "github.com/dbl-works/terraform//aws/aurora?ref=v2021.07.01"

  project     = "myproject"
  environment = "staging"
  region      = "eu-central-1"

  # Networking
  vpc_id     = module.vpc.id
  subnet_ids = module.vpc.subnet_private_ids

  # Security
  kms_key_arn = module.kms.key_arn
  allow_from_security_groups = [
    module.ecs.security_group_id
  ]

  # Credentials (stored in AWS Secrets Manager)
  username = "root"
  password = var.aurora_password
}
```

### With Zero-ETL Integration Support

```terraform
module "aurora" {
  source = "github.com/dbl-works/terraform//aws/aurora?ref=v2021.07.01"

  project     = "myproject"
  environment = "staging"
  region      = "eu-central-1"

  # Networking
  vpc_id     = module.vpc.id
  subnet_ids = module.vpc.subnet_private_ids

  # Security
  kms_key_arn = module.kms.key_arn
  allow_from_security_groups = [
    module.ecs.security_group_id
  ]

  # Credentials
  username = "root"
  password = var.aurora_password

  # Zero-ETL Integration
  enable_replication = true  # Enables logical replication for zero-ETL

  # Aurora Configuration
  instance_count = 2  # 1 writer + 1 reader
  instance_class = "db.r6g.large"
  engine_version = "16.4"
}
```

### Using with Redshift Serverless

```terraform
module "aurora" {
  source = "github.com/dbl-works/terraform//aws/aurora?ref=v2021.07.01"

  # ... basic configuration ...
  enable_replication = true
}

module "redshift_serverless" {
  source = "github.com/dbl-works/terraform//aws/redshift/serverless?ref=v2021.07.01"

  # ... basic configuration ...

  # RDS Integration (automatically creates zero-ETL integration)
  source_rds_arn               = module.aurora.cluster_arn  # Use cluster_arn!
  source_rds_security_group_id = module.aurora.security_group_id
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project` | Project name | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `vpc_id` | VPC ID where Aurora will be deployed | `string` | n/a | yes |
| `subnet_ids` | List of subnet IDs for Aurora | `list(string)` | n/a | yes |
| `kms_key_arn` | KMS key ARN for encryption | `string` | n/a | yes |
| `username` | Master username | `string` | `"root"` | no |
| `password` | Master password | `string` | n/a | yes |
| `instance_count` | Number of Aurora instances | `number` | `1` | no |
| `instance_class` | Instance class for Aurora instances | `string` | `"db.serverless"` | no |
| `instances` | Per-instance class and optional failover promotion tier list (overrides `instance_count` and `instance_class`) | `list(object({ instance_class = string, promotion_tier = optional(number, 0) }))` | `null` | no |
| `storage_type` | Aurora storage configuration (`"aurora"` or `"aurora-iopt1"`) | `string` | `null` | no |
| `min_capacity` | Minimum Aurora Serverless v2 capacity in ACUs | `number` | `0.0` | no |
| `max_capacity` | Maximum Aurora Serverless v2 capacity in ACUs | `number` | `2.0` | no |
| `seconds_until_auto_pause` | Idle seconds before Serverless v2 auto-pause (300 to 86400, requires `min_capacity = 0`) | `number` | `null` | no |
| `engine_version` | Aurora PostgreSQL engine version | `string` | `"17.4"` | no |
| `enable_replication` | Enable logical replication for zero-ETL | `bool` | `false` | no |
| `backup_retention_period` | Backup retention period in days | `number` | `7` | no |
| `allow_from_cidr_blocks` | CIDR blocks allowed to connect | `list(string)` | `[]` | no |
| `allow_from_security_groups` | Security groups allowed to connect | `list(string)` | `[]` | no |
| `snapshot_identifier` | DB snapshot to create cluster from | `string` | `null` | no |
| `delete_automated_backups` | Delete automated backups after cluster deletion | `bool` | `true` | no |

## Outputs

### Aurora-Specific Outputs

| Name | Description |
|------|-------------|
| `cluster_arn` | Aurora cluster ARN (use for zero-ETL integration) |
| `cluster_writer_endpoint` | Aurora cluster writer endpoint |
| `cluster_reader_endpoint` | Aurora cluster reader endpoint |
| `cluster_identifier` | Aurora cluster identifier |
| `cluster_members` | List of Aurora cluster members |
| `cluster_resource_id` | Aurora cluster resource ID (for IAM auth) |
| `security_group_id` | Aurora security group ID |

### IAM Outputs

| Name | Description |
|------|-------------|
| `iam_group_arns_db_connect` | Map of IAM group ARNs for database connections (admin, readonly) |
| `iam_group_arn_view` | IAM group ARN for viewing Aurora clusters |

## IAM Database Authentication

The module creates IAM groups for database access:

- **Admin group**: `{name}-aurora-db-connect-admin` - Full database access
- **Readonly group**: `{name}-aurora-db-connect-readonly` - Read-only database access
- **View group**: `{name}-aurora-view` - Permission to list/describe clusters

Add users to these groups to grant database access via IAM authentication.

## Zero-ETL Integration

To enable zero-ETL integration with Amazon Redshift:

1. **Set `enable_replication = true`** in your Aurora module
2. **Use `cluster_arn` output** as `source_rds_arn` in Redshift Serverless module
3. **Aurora version** must be 16.4+ for PostgreSQL

The Redshift Serverless module will automatically create the zero-ETL integration when you provide the Aurora cluster ARN.

The module automatically configures the required parameters:

- `rds.logical_replication = 1`
- `aurora.enhanced_logical_replication = 1`
- `aurora.logical_replication_backup = 0`
- `aurora.logical_replication_globaldb = 0`

## Migration from RDS Module

Aurora module provides compatibility outputs to ease migration:

```terraform
# Old RDS usage
module "rds" {
  source = "github.com/dbl-works/terraform//aws/rds?ref=v2021.07.01"
  # ... configuration ...
}

# References work the same
resource "something" {
  database_url = module.rds.database_url
  security_group = module.rds.database_security_group_id
}

# New Aurora usage
module "aurora" {
  source = "github.com/dbl-works/terraform//aws/aurora?ref=v2021.07.01"
  # ... configuration ...
}

# Same references still work
resource "something" {
  database_url = module.aurora.database_url        # Points to cluster_endpoint
  security_group = module.aurora.database_security_group_id  # Points to security_group_id
}
```

## I/O-Optimized storage and rolling provisioned cutover

Set `storage_type = "aurora-iopt1"` to switch an existing cluster from Aurora Standard to Aurora I/O-Optimized storage in place. You can switch back to `"aurora"` (Standard) at any time, and AWS enforces a 30-day cooldown before switching into `"aurora-iopt1"` again. Leave `storage_type` unset (`null`) when AWS manages the default.

The `instances` variable accepts an ordered list of `{ instance_class, promotion_tier }` objects and keeps `count`-indexed `aws_rds_cluster_instance.cluster_instances[N]` state addresses intact without state moves. While any entry uses `"db.serverless"`, the module keeps `serverlessv2_scaling_configuration` on the cluster. Once all entries are provisioned classes, the block is omitted.

To migrate a two-node Serverless v2 cluster (`[0]` and `[1]`) to provisioned instances with minimal downtime, check `DBClusterMembers[].IsClusterWriter` before every apply and run five applies in order.

1. **Expand.** Replace `instance_count` and `instance_class` with `instances`. Keep `[0]` and `[1]` as `"db.serverless"` with `promotion_tier = 2`, and append `[2]` as a temporary provisioned reader with `promotion_tier = 1`.
2. **Convert reader.** Change the verified serverless reader index to its target provisioned writer class at `promotion_tier = 0` so AWS modifies it while it serves no writes.
3. **Planned failover.** Trigger a manual RDS cluster failover targeting the converted provisioned reader. Verify the old serverless writer is now a reader.
4. **Convert demoted writer.** Change the verified demoted serverless index to its target provisioned reader class.
5. **Contract.** Verify `[2]` is not the writer, drop `[2]` from `instances`, and set steady-state `promotion_tier` values on `[0]` and `[1]`.

```terraform
module "aurora" {
  source = "github.com/dbl-works/terraform//aws/aurora?ref=v2026.11.18"

  # ... networking, security, credentials ...

  storage_type = "aurora-iopt1"
  instances = [
    { instance_class = "db.r8g.xlarge", promotion_tier = 0 },
    { instance_class = "db.r8g.xlarge", promotion_tier = 1 },
  ]
}
```

## Important Notes

- **Multi-AZ**: Aurora is inherently Multi-AZ, no configuration needed
- **Storage**: Aurora storage automatically scales, no allocated_storage parameter
- **Instances**: Reader instances can be added/removed for read scaling
- **Backups**: Aurora supports point-in-time recovery automatically
- **Zero-ETL**: Only supported with Aurora PostgreSQL 16.4+

## Best Practices

1. **Use at least 2 instances** for production (1 writer + 1 reader)
2. **Enable replication** only if you plan to use zero-ETL integration
3. **Use r6g instance types** for best performance/cost ratio
4. **Keep engine_version updated** for security and features
5. **Use proper security groups** instead of CIDR blocks when possible
