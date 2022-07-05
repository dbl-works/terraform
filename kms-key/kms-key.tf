resource "aws_kms_key" "key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.multi_region

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
