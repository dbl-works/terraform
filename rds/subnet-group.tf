resource "aws_db_subnet_group" "main" {
  name       = var.subnet_group_name == null ? local.name : var.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name        = var.subnet_group_name == null ? local.name : var.subnet_group_name
    Project     = var.project
    Environment = var.environment
  }
}
