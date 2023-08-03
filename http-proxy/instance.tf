resource "aws_instance" "main" {
  ami                         = var.ami_id
  subnet_id                   = var.public_subnet_id
  key_name                    = aws_key_pair.main.key_name
  instance_type               = var.instance_type
  associate_public_ip_address = true
  monitoring                  = true

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 10
    volume_type           = "gp2"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-httpproxy"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = data.aws_eip.main.id
}
