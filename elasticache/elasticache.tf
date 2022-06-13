resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project}-${var.environment}"
  description                = "Collection of Redis cache clusters for ${var.project}-${var.environment}"
  engine                     = "redis"
  node_type                  = var.node_type
  num_cache_clusters         = var.node_count
  parameter_group_name       = var.parameter_group_name
  engine_version             = var.engine_version
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn
  snapshot_retention_limit   = var.snapshot_retention_limit
  # When you change an attribute, such as engine_version,
  # by default the ElastiCache API applies it in the next maintenance window.
  # Because of this, Terraform may report a difference in its planning phase
  # because the actual modification has not yet taken place.
  # Set apply_immediately flag to true to instruct the service to apply the change immediately
  # but will result in a brief downtime as servers reboots.
  apply_immediately           = true
  preferred_cache_cluster_azs = var.availability_zones
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
