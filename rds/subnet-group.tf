resource "aws_db_subnet_group" "main" {
  name       = local.name
  subnet_ids = var.subnet_ids

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
