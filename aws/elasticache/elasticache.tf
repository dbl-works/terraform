resource "aws_elasticache_replication_group" "non_cluster_mode" {
  count                       = var.cluster_mode ? 0 : 1
  replication_group_id        = local.cluster_name
  description                 = "Collection ${var.engine} (cluster mode disabled) for ${var.project}-${var.environment}"
  engine                      = var.engine
  node_type                   = var.node_type
  num_cache_clusters          = var.node_count
  preferred_cache_cluster_azs = var.availability_zones
  parameter_group_name        = var.parameter_group_name == null ? aws_elasticache_parameter_group.main[0].id : var.parameter_group_name
  engine_version              = "${var.major_version}.${var.minor_version}"
  port                        = 6379
  subnet_group_name           = aws_elasticache_subnet_group.main.name
  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = var.transit_encryption_enabled # we should not allow setting this to false, but we have legacy apps that need to be upgraded
  transit_encryption_mode     = var.transit_encryption_mode
  kms_key_id                  = var.kms_key_arn
  snapshot_retention_limit    = var.snapshot_retention_limit
  # When you change an attribute, such as engine_version,
  # by default the ElastiCache API applies it in the next maintenance window.
  # Because of this, Terraform may report a difference in its planning phase
  # because the actual modification has not yet taken place.
  # Set apply_immediately flag to true to instruct the service to apply the change immediately
  # but will result in a brief downtime as servers reboots.
  apply_immediately          = true
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.automatic_failover_enabled
  data_tiering_enabled       = var.data_tiering_enabled

  security_group_ids = [
    "${aws_security_group.main.id}",
  ]

  tags = {
    Project     = var.project
    Environment = var.environment
  }

  # Ignore engine version changes since AWS will auto-update minor version changes
  lifecycle {
    ignore_changes = [
      engine_version,
      num_cache_clusters
    ]
  }
}

resource "aws_elasticache_replication_group" "cluster_mode" {
  count                      = var.cluster_mode ? 1 : 0
  replication_group_id       = local.cluster_name
  description                = "Collection of ${var.engine} (clusters mode) for ${var.project}-${var.environment}"
  engine                     = var.engine
  node_type                  = var.node_type
  parameter_group_name       = var.parameter_group_name == null ? aws_elasticache_parameter_group.main[0].id : var.parameter_group_name
  engine_version             = "${var.major_version}.${var.minor_version}"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled # we should not allow setting this to false, but we have legacy apps that need to be upgraded
  transit_encryption_mode    = var.transit_encryption_mode
  kms_key_id                 = var.kms_key_arn
  snapshot_retention_limit   = var.snapshot_retention_limit
  apply_immediately          = true
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = true
  data_tiering_enabled       = var.data_tiering_enabled

  security_group_ids = [
    "${aws_security_group.main.id}",
  ]

  # Cluster Mode
  num_node_groups         = var.shard_count
  replicas_per_node_group = var.replicas_per_node_group

  tags = {
    Project     = var.project
    Environment = var.environment
  }

  # Ignore engine version changes since AWS will auto-update minor version changes
  lifecycle {
    ignore_changes = [
      engine_version,
    ]
  }
}

locals {
  family = var.engine == "valkey" ? (
    var.major_version == 7 ? "valkey7" : "valkey8"
  ) : (
    var.major_version == 6 ? "redis6.x" : "redis7"
  )
}

resource "aws_elasticache_parameter_group" "main" {
  count = var.parameter_group_name == null ? 1 : 0

  name   = local.cluster_name
  family = local.family

  parameter {
    name  = "maxmemory-policy"
    value = var.maxmemory_policy
  }

  parameter {
    name  = "cluster-enabled"
    value = var.cluster_mode ? "yes" : "no"
  }
}
