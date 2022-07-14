resource "aws_elasticache_subnet_group" "main" {
  name       = local.name
  subnet_ids = var.subnet_ids
}
