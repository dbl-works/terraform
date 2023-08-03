resource "aws_eip" "main" {
  count = var.eip == null ? 1 : 0

  tags = {
    Name        = "${var.project}-${var.environment}-httpproxy"
    Project     = var.project
    Environment = var.environment
  }
}

locals {
  eip = var.eip == null ? aws_eip.main[0].public_ip : var.eip
}
