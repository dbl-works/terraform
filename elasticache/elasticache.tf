# Non encrypted basic cluster, for caching
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.project}-${var.environment}"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.node_count
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  apply_immediately    = true

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
    ]
  }
}
