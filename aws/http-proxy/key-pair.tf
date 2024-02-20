resource "aws_key_pair" "main" {
  key_name   = "${var.project}-${var.environment}-httpproxy"
  public_key = var.public_key

  tags = {
    Name        = "${var.project}-${var.environment}-httpproxy"
    Project     = var.project
    Environment = var.environment
  }
}
