resource "aws_eip" "main" {
  count = var.eip == null ? 1 : 0

  tags = {
    Name        = "${var.project}-${var.environment}-httpproxy"
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_eip" "main" {
  public_ip = var.eip == null ? aws_eip.main[0].public_ip : var.eip
}

output "eip" {
  value = data.aws_eip.main.public_ip
}
