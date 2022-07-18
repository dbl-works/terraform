resource "aws_elasticache_subnet_group" "main" {
  name       = local.elasticache_name
  subnet_ids = var.subnet_ids
}
