resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-elasticache"
  subnet_ids = var.subnet_ids
}
